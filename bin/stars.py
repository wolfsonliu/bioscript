import numpy as np
import pandas as pd
from scipy import stats
from statsmodels.distributions.empirical_distribution import ECDF
import argparse
import warnings

def calculate_guide_star(guide, group, score, ascending):
    # make input DF
    data = pd.DataFrame(
        {
            'guide': pd.Series(guide),
            'group': pd.Series(group),
            'score': pd.Series(score)
        }
    )
    data = data.assign(
        total_rank=data['score'].rank(
            method='dense',
            ascending=ascending
        ),
        total_pct=data['score'].rank(
            method='dense',
            ascending=ascending,
            pct=True
        )
    )
    data = data.assign(
        group_rank=data.groupby('group')['score'].rank(
            method='dense',
            ascending=ascending
        )
    )
    data = pd.merge(
        data,
        pd.DataFrame(
            {'group_guide_num':data.groupby('group')['guide'].count()}
        ),
        left_on='group', right_index=True
    )
    data = data.assign(
        star=-np.log10(stats.binom.pmf(
            data['group_rank'],
            data['group_guide_num'],
            data['total_pct']
        ))
    )
    return data


def calculate_group_star_basic(guide, group, score, ascending, threshold):
    guidestar = calculate_guide_star(
        guide=guide, group=group, score=score, ascending=ascending
    )
    guidestar = guidestar.loc[guidestar['total_pct'] <= threshold]
    groupresult = guidestar.groupby('group')['star'].max().reset_index(drop=False)
    return groupresult


def generate_guide_star_null(guide, group, ascending):
    guidestarnull = calculate_guide_star(
        guide=guide, group=group,
        score=np.random.randn(len(group)),
        ascending=ascending
    )
    return guidestarnull


def generate_group_star_null(guide,
                             group,
                             ascending,
                             threshold,
                             iteration=100):
    result = list()
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        for i in range(int(iteration)):
            result.append(
                calculate_group_star_basic(
                    guide=guide, group=group,
                    score=np.random.randn(len(group)),
                    ascending=ascending,
                    threshold=threshold
                )
            )
    return pd.concat(result, axis=0)


def calculate_group_star(guide,
                         group,
                         score,
                         ascending,
                         threshold,
                         iteration=100):
    # read data
    data = calculate_group_star_basic(
                guide=guide, group=group,
                score=score,
                ascending=ascending,
                threshold=threshold
            )
    # observation cdf
    obs_cdf = ECDF(data.sort_values('star')['star'])
    # generate null distribution
    nulldata = generate_group_star_null(
        guide=guide,
        group=group,
        ascending=ascending,
        threshold=threshold,
        iteration=iteration
    )
    # null cdf
    null_cdf = ECDF(nulldata.sort_values('star')['star'])
    # calculate FDR
    data = data.assign(
        n_cdf=null_cdf(data['star'] - 0.000001),
        o_cdf=obs_cdf(data['star'] - 0.000001)
    )
    data=data.assign(
        p=1 - data['n_cdf'],
        fdr= (1 - data['n_cdf']) / (1 - data['o_cdf'])
    )
    # correct FDR
    data.loc[data['fdr'].isin([np.inf]), 'fdr'] = 0
    data.loc[data['fdr'] > 1, 'fdr'] = 1
    return data


def main_star(inputfile,
              outprefix,
              threshold,
              iteration):
    data = pd.read_table(
        inputfile, sep='\t', header=None
    )
    data.columns = ['group', 'guide', 'score']
    outfilename = {
        'False': [
            outprefix + '_lfc_descending_guide.txt',
            outprefix + '_lfc_descending_group.txt'
        ],
        'True':  [
            outprefix + '_lfc_ascending_guide.txt',
            outprefix + '_lfc_asscending_group.txt'
        ]
    }
    for ascending in [False, True]:
        guideresult = calculate_guide_star(
            data['guide'], data['group'], data['score'], ascending=ascending
        )
        guideresult.to_csv(
            outfilename[str(ascending)][0], sep='\t', index=False
        )
        groupresult = calculate_group_star(
            guide=data['guide'], group=data['group'], score=data['score'],
            ascending=ascending, threshold=threshold, iteration=iteration
        )
        guideresult.to_csv(
            outfilename[str(ascending)][1], sep='\t', index=False
        )


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Calculate sgRNA STAR Score.'
    )
    parser.add_argument(
        '-i', '--input',
        action='store',
        help='[str: file path] Log Fold Change table (tab separated txt file, without header), should include <gene> <guide> <lfc>.',
        required=True
    )
    parser.add_argument(
        '-o', '--out-prefix',
        action='store',
        default='star',
        help='[str: file path] Output file prefix.'
    )
    parser.add_argument(
        '-t', '--threshold',
        action='store', type=float,
        default=0.1,
        help='[float: 0.0~1.0] Top guides to be considered in output.'
    )
    parser.add_argument(
        '-n', '--iteration',
        action='store', type=int,
        default=100,
        help='[int] iteration number for generation of null distribution in FDR calculation, large number means lower FDR and longer computation time.'
    )
    args = vars(parser.parse_args())
    main_star(
        inputfile=args['input'],
        outprefix=args['out_prefix'],
        threshold=args['threshold'],
        iteration=args['iteration']
    )


####################
