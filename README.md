# pwcmp_rating_unified

Code for scaling together results of pairwise comparison and rating experiments.

If using the code please cite:

[1] M. Perez-Ortiz, A. Mikhailiuk, E. Zerman, V. Hulusic, G. Valenzise and R. K. Mantiuk, “From pairwise comparisons and rating to a unified quality scale”, Transactions on Image Processing (TIP), 2019. Accessible at https://www.cl.cam.ac.uk/~rkm38/pdfs/perezortiz2019unified_quality_scale.pdf

## Usage

The code for this example can be found in the examples folder (example1.m) 
To produce a unified scale we use a pairwise comparison matrix D (NxN) and 
a rating matrix M (NxK) and datasets_sizes (1xT), where N is 
the total number of conditions and K is the total number of observers.

For example we want to scale together two datasets with 4 and 5 conditions. 
Both datasets contain pairwise comparisons and rating measurements. 

Matrix with pairwise comparisons has N1 rows and collumns, where N1 is the 
size of the DS1.
```
D1 = [0 0 0 0
      1 0 0 1 
      1 1 0 1
      1 0 0 0];
```
Matrix with rating has N1 rows and K1 collumns, where K1 is the number of 
observers giving their measurements 
```
M1 = [3 1 3 1 2;
      NaN NaN NaN NaN NaN;
      6 7 7 7 7;
      7 6 9 7 8];
```
Notice that in the case of DS1 we have full matrix of comparisons, but one 
row in the rating matrix is missing.

For the DS2 condition 2 is not connected with the rest via pairwise
comparisons, however, linked via rating experiments. 

```
D2 = [0 0 1 1 0;
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
comparisons. Resulting matrix D must look like that:

```
D = [D1, (comparisons D1 to D2);
    (comparisons D2 to D1), D2];

D = [0 0 0 0 0 3 3 0 0;
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
Example of experiments with reference can be found in example3.m. For that 
use mixing_ref.m

To improve the convergence we also recomend dividing the mean opinion scores
by the maximum allowed score in the rating experiment.

The resultant matrix with mean opinion scores will look like that:

```
M = [M1,            (NaN,...,NaN);
    (NaN,...,NaN),   M2];
```
We now can run the code to unify disjoint datasets together:

```
[Q,a,b,c] = mixing(D,M, datasets_sizes)

```

Q's are the unified quality scores for all datasets. a,b and c are (1xT) 
and are the parameters of the model for each of the datasets.

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
