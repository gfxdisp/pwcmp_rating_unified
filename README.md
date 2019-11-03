# pwcmp_rating_unified

Code for scaling together results of pairwise comparison and rating experiments.

If using the code please cite:

[1] M. Perez-Ortiz, A. Mikhailiuk, E. Zerman, V. Hulusic, G. Valenzise and R. K. Mantiuk, “From pairwise comparisons and rating to a unified quality scale”, Transactions on Image Processing (TIP), 2019. Accessible at https://www.cl.cam.ac.uk/~rkm38/pdfs/perezortiz2019unified_quality_scale.pdf

The scaling procedure achieves several, non-trivial goals:

* Firstly, it relates the quality scores coming from different protocols (rating and pairwise comparisons).

* Secondly, it accounts for the accuracy/sensitivity of the protocol used in each experiment and brings the quality values into a unified scale. 

* Finally, it accounts for the uncertainty in measurements; the conditions that received more measurements have higher impact on the likelihood and the final solution. Overall, such an integrative approach to modeling experimental data leads to more accurate quality estimates and better "ground truth" data.

## Usage

The code for this example can be found in the examples folder (example1.m). 
To produce a unified scale we need a pairwise comparison matrix C (NxN) and 
a rating matrix M (NxK), where N is the total number of conditions and K is 
the total number of subjects in rating experiments.

Let's consider an example where we want to scale together two datasets - DS1 and DS2 with N1 = 4 and N2 = 5 conditions. 
Both datasets contain pairwise comparisons and rating measurements. 

Matrix with pairwise comparisons for DS1 has N1 rows and columns:
```
C1 = [0 0 0 0
      1 0 0 1 
      1 1 0 1
      1 0 0 0];
```
Matrix with rating has N1 rows and K1 columns, where K1 is the number of 
subjects participating in rating experiments for DS1: 
```
M1 = [3 1 3 1 2;
      NaN NaN NaN NaN NaN;
      6 7 7 7 7;
      7 6 9 7 8];
```
Notice that in the case of DS1 we have a full matrix of comparisons, but one 
row in the rating matrix is missing.

Below are matrix with pairwise comparisons and rating scores for DS2. Notice, 
that condition 2 is not connected with the rest via pairwise comparisons, however, linked via rating experiments. 

```
C2 = [0 0 1 1 0;
      0 0 0 0 0;
      0 0 0 1 1;
      0 0 0 0 1;
      1 0 0 0 0];

M2 = [5  4  5;
      3  4  4;
      4  6  4;
      4  6  7;
      10 9  9];
```
To align datasets together we first need to link them with pairwise 
comparisons. Resulting matrix C must look like that:

```
C = [C1, (comparisons C1 to C2);
    (comparisons C1 to C2), C2];

C = [0 0 0 0 0 3 3 0 0;
     1 0 0 1 3 0 4 0 0;
     1 1 0 1 0 0 0 0 3;
     1 0 0 0 0 0 0 0 0;
     0 3 0 0 0 0 1 1 0;
     3 0 0 0 0 0 0 0 0;
     3 2 0 0 0 0 0 1 1;
     0 0 0 0 0 0 0 0 1;
     0 0 3 0 1 0 0 0 0];
```

The next step should be conducted only if rating and ranking experiments 
use reference conditions to compare to. For example in image quality assessment
experiments it is common to have a reference condition for each dataset.
The scores of all other conditions are assigned relative to it. In this case rating 
matrices for each of the datasets must be converted to DMOS by subtracting 
from all entries the value of the first (reference) condition, i.e. M1 = M1 - M1(1,:). 
An example of unifying datasets with reference can be found in example3.m. Note, that for that 
example with use a slightly different optimisation procedure: mixing_ref.m

To improve the convergence we also recommend dividing the mean opinion scores
by the maximum possible score of the rating experiment.

The resultant matrix with mean opinion scores will look like that:

```
M = [M1,            (NaN,...,NaN);
    (NaN,...,NaN),   M2];

M = [3    1    3    1    2    NaN  NaN  NaN;
     NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN;
     6    7    7    7    7    NaN  NaN  NaN;
     7    6    9    7    8    NaN  NaN  NaN;
     NaN  NaN  NaN  NaN  NaN  5    4    5;
     NaN  NaN  NaN  NaN  NaN  3    4    4;
     NaN  NaN  NaN  NaN  NaN  4    6    4;
     NaN  NaN  NaN  NaN  NaN  4    6    7;
     NaN  NaN  NaN  NaN  NaN  10   9    9];

```
We now can run the code to unify disjoint datasets together:

```
% datasets_sizes is a 1xT array, holding sizes of the disjoint datasets, here
% T is the number of datasets.
[Q,a,b,c] = mixing(C,M, datasets_sizes)

```

The function returns: Q - the unified quality scores for all datasets. a,b and c - (1xT) arrays
with the parameters of the model for each of the datasets.

For more please see:
```
% Example from this read me file 
example1.m 

% Example with adjustable parameters, no reference
example2.m

% Example with adjustable parameters, with reference
example3.m
```

## Literature

When using the code, please cite [1]: 

[1] M. Perez-Ortiz, A. Mikhailiuk, E. Zerman, V. Hulusic, G. Valenzise and R. K. Mantiuk, “From pairwise comparisons and rating to a unified quality scale”, Transactions on Image Processing (TIP), 2019. Accessible at https://www.cl.cam.ac.uk/~rkm38/pdfs/perezortiz2019unified_quality_scale.pdf

We also make use of the pw_scale function [2]:

[2] M. Perez-Ortiz and R. K. Mantiuk, “A practical guide and software for analysing pairwise comparison experiments”, arXiv Stat.AP, 2017, accessible at https://arxiv.org/abs/1712.03686

## License

MIT
