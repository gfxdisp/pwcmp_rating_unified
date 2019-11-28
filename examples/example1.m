clear all

% Add path to the mixing code
addpath ('../')

% Ground truth scores used to generate matrices D and M
Q_true = [0,0.4084,0.9614,0.9797,0.1016,0.1708,0.1780,0.2378,0.2785];

C = [0, 0, 0, 3, 0, 3, 0, 0, 0;
     6, 0, 0, 0, 0, 6, 0, 0, 5;
     0, 0, 0, 0, 0, 0, 0, 0, 0;
     3, 6, 0, 0, 6, 0, 0, 9, 0;
     0, 0, 0, 4, 0, 2, 3, 2, 3;
     7, 4, 0, 0, 4, 0, 3, 3, 3;
     0, 0, 0, 0, 3, 3, 0, 3, 4;
     0, 0, 0, 1, 4, 3, 3, 0, 2;
     0, 5, 0, 0, 3, 3, 2, 4, 0];

M = [3     4     5     5   NaN   NaN   NaN   NaN   NaN;
     5     7     7     7   NaN   NaN   NaN   NaN   NaN;
     9     7     8     9   NaN   NaN   NaN   NaN   NaN;
     9     9     9     8   NaN   NaN   NaN   NaN   NaN;
   NaN   NaN   NaN   NaN     3     2     3     3     2;
   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN;
   NaN   NaN   NaN   NaN     4     3     3     3     2;
   NaN   NaN   NaN   NaN     3     3     3     4     2;
   NaN   NaN   NaN   NaN     3     2     4     4     3];
      
       
datasets_sizes = [4,5];

% Unify the scores 
[Q_mixing, a, b, c] = mixing(C, M, datasets_sizes);
    

H = figure;
plot(Q_true(1:4),Q_mixing(1:4),'b*')
hold on
plot(Q_true(5:end),Q_mixing(5:end),'ro')
legend({'Dataset 1', 'Dataset 2'})
grid on
ylabel('Predicted')
xlabel('True')
xlim([0 1.5])
ylim([0 1.5])
pbaspect([1 1 1])
set(findall(H,'-property','FontSize'),'FontSize',14)
