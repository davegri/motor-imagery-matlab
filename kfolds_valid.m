% perform kfolds cross validation procedure. Divide samples into k groups,
% (if length(samples) isn't a multiple of k the last group gets the
% remainder). Train and test k classifiers, each time leaving one group out
% to validate on, training on the rest.
% Inputs:
%   k: number of folds (groups of samples)
%   samples: matrix of dimensions (n_samples,n_features)
%   labels: vector of the same amount of rows as samples, corresponding to
%   the samples' ground truth labels.
% Outputs:
%   acc: vector of k accuracies (correct_predictions/n_predictions) for
%   each model trained.
function [val_acc, tr_acc] = kfolds_valid(k, samples, labels)
    val_acc = zeros(k,1); % allocate memory for vector of classifier accuracies
    tr_acc = zeros(k,1); % allocate memory for vector of classifier accuracies
    n_samples = size(samples,1);

    rand_idxs = randperm(n_samples); % shuffle indexes
    fold_size = floor(n_samples/k); % round down fold size
    remain = mod(n_samples, fold_size); % calculate remaining samples after rounded down fold size
    
    % sort fold indxs into k-1 folds of size: fold_size and 1 fold of size: fold_size + remain
    folds = mat2cell(rand_idxs, 1, [ones(1,k-1)*fold_size fold_size + remain]); 
    for f = 1:k
        % 1 fold for validation
        valid_idxs = folds{f}; 
        % all idxs not in validation go into training
        train_idxs = setdiff(1:n_samples,valid_idxs); 
        
        % get samples
        valid_samples = samples(valid_idxs,:);
        train_samples = samples(train_idxs,:);
        
        % get labels
        train_labels = labels(train_idxs)';
        valid_labels = labels(valid_idxs)';
        
        % train and predict validation labels
        [pred_valid_labels, train_err] = classify(valid_samples, train_samples, train_labels);
        
        % calculate classifier accuracy for current fold
        val_acc(f) = 100 * sum(pred_valid_labels == valid_labels) / length(valid_labels);
     
        % calculate training accuracy from train_err
        tr_acc(f) = 100*(1 - train_err);
    end
end
