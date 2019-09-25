clear all

% Add path to the mixing code
addpath ('../')

% Ground truth scores used to generate matrices D and M
Q_true = [0    0.3324    0.8835    0.8975    0.0182    0.0807    0.0808    0.2772    0.7478];

D = [0 0 0 0 0 3 3 0 0;
     1 0 0 1 3 0 4 0 0;
     1 1 0 1 0 0 0 0 3;
     1 0 0 0 0 0 0 0 0;
     0 3 0 0 0 0 1 1 0;
     3 0 0 0 0 0 0 0 0;
     3 2 0 0 0 0 0 1 1;
     0 0 0 0 0 0 0 0 1;
     0 0 3 0 1 0 0 0 0];
      
M = [3    1    3    1    2    NaN  NaN  NaN;
     NaN   NaN    NaN    NaN    NaN    NaN  NaN  NaN;
     6    7    7    7    7    NaN  NaN  NaN;
     7    6    9    7    8    NaN  NaN  NaN;
     NaN  NaN  NaN  NaN  NaN  5    4    5;
     NaN  NaN  NaN  NaN  NaN  3    4    4;
     NaN  NaN  NaN  NaN  NaN  4    6    4;
     NaN  NaN  NaN  NaN  NaN  4    6    7;
     NaN  NaN  NaN  NaN  NaN  10   9    9];
       
       
datasets_sizes = [4,5];

% Unify the scores 
[Q_mixing, a, b, c] = mixing(D, M, datasets_sizes);
    

figure
plot(Q_true,Q_mixing,'*')
ylabel('Predicted')
xlabel('True')


