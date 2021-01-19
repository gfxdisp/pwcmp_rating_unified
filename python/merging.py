import math
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize
from scipy.stats import norm 
from scipy.special import comb

def process_data(D,M_os):
    '''
    Function to generate the data in the format convenient for optimization procedure
    '''
    
    # Number of elemnts
    N = D.shape[1]
    
    # Find non zero elements 
    nnz   = (D+D.T)>0
    D_nnz = D[nnz]
    DT_nnz = D.T[nnz]
    Dt = D.T
    
    # Find n choose k matrix for the binomial distribution
    D_sum = D+Dt
    NK = np.zeros((N,N))
    for ii in range (0,N):
        for jj in range (0,N):
            NK[ii, jj] = comb(D_sum[jj,ii], D[ii,jj])

    NK_nnz = NK[nnz]
    
    return nnz, D_nnz, DT_nnz, NK_nnz


def initial_value(datasets_sizes):
    '''
    Set the inital value for the optimized parameters
    '''
    b_init = np.ones(len(datasets_sizes))
    a_init = np.ones(len(datasets_sizes))
    c_init = np.ones(len(datasets_sizes))
        
    x0 = np.zeros((sum(datasets_sizes)+3*len(datasets_sizes)),dtype=float)
    x0[sum(datasets_sizes):] = np.concatenate((a_init,b_init,c_init))

    return x0

def exp_prob(x,nnz, D_nnz, DT_nnz, NK_nnz,mos,datasets_sizes):
    
    # Anchor the first element to zero
    x[0] = 0
    
    N = sum(datasets_sizes)
    
    # Set the variance for the observer model
    sigma_cdf = 1.4826
    sigma = sigma_cdf/(math.sqrt(2))
    
    # Number of datasets is required to find the number of separate parameters (a,b and c)
    num_datasets = len(datasets_sizes)
    
    
    # Extract the optimized variables
    q = x[:N]
    a = np.ones(sum(datasets_sizes))
    b = np.ones(sum(datasets_sizes))
    c = np.ones(sum(datasets_sizes))

    # Create arrays with parameters a,b and c of the dataset sizes 
    idx = 0
    for ii in range(0,len(datasets_sizes)):
        a[idx:(idx+datasets_sizes[ii])] = a[idx:(idx+datasets_sizes[ii])]*x[N+ii]
        b[idx:(idx+datasets_sizes[ii])] = b[idx:(idx+datasets_sizes[ii])]*x[N+num_datasets+ii]
        c[idx:(idx+datasets_sizes[ii])] = c[idx:(idx+datasets_sizes[ii])]*x[N+2*num_datasets+ii]
        idx+=datasets_sizes[ii]
    
    # Ensure that c is greater than 0
    c[c<0.0]=1e-10
    
    # Find probability matrix for rating
    rep_mat_abc = np.reshape(np.repeat(a*q+b,mos.shape[1], axis = 0),(mos.shape[0],mos.shape[1]))
    p_mos = norm.pdf(mos, rep_mat_abc , a*c*sigma)
    p_mos = np.nan_to_num(p_mos,nan = 1.0)
    
    # Find probability matrix for pairwise comparisons
    xrrsh = np.reshape(np.repeat(q,N, axis = 0),(N,N))
    Pd    = norm.cdf(xrrsh-xrrsh.T,0,sigma_cdf)
    p_pwc = np.multiply(NK_nnz,np.multiply((Pd[nnz]**D_nnz),(1-Pd[nnz])**DT_nnz))

    # Find prior probability
    prior = norm.pdf(q, np.mean(q), math.sqrt(N)*sigma)
    
    # Ensure that there are no zeros in the p matrices
    p_pwc[p_pwc<10**-20] = 10**-20
    p_mos[p_mos<10**-20] = 10**-20
    prior[prior<10**-20] = 10**-20

    # Calculate the log likelihood
    P1 = -np.sum(np.log(p_pwc)) 
    P2 = -np.sum(np.sum(np.log(p_mos)))
    P3 = -np.sum(np.log(prior))
    P  = P1+P2+P3

    return P

def merge_datasets(pwc,mos,datasets_sizes):
    
    
    nnz, D_nnz, DT_nnz, NK_nnz = process_data(pwc,mos)
    
    x0 = initial_value(datasets_sizes)
    
    res = minimize(exp_prob, x0, args =(nnz, D_nnz, DT_nnz, NK_nnz, mos,datasets_sizes), method='SLSQP', options={'disp': True},tol =1e-12)
    
    N = sum(datasets_sizes)
    
    Q = res.x[:N]
    a = res.x[N:(N+len(datasets_sizes))]
    b = res.x[(N+len(datasets_sizes)):N+2*len(datasets_sizes)]
    nu = res.x[N+2*len(datasets_sizes):]
    
    return Q, a, b, nu