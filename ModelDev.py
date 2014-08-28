## All imports -----------------------------------
import sys, os, datetime
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier

print "** start_datetime: %s" % datetime.datetime.now()

## Development Configuration ---------------------
class G:
    # dir_root = os.getcwd() + '/'
    dir_root = "/Users/beingzy/Documents/Projects/stockRF/"
    dir_data = dir_root + 'data/'
    dir_results = dir_root + 'results/'
    train_ratio = .7
    test_ratio  = .3
    valid_tratio = 0
    ntrees = 50
    parall = {"ncores": 2}

## Import data files ("*.csv") ------------------------
data_files = [filename for filename in os.listdir(G.dir_data) if filename.find(".csv") is not -1 ]
x_data_files = [f for f in data_files if f.find("_Y_") == -1 ]
y_data_files = [f for f in data_files if f.find("_Y_") != -1 ]

## Load data and concatenate X variables
X = pd.read_csv(G.dir_data + x_data_files[0], sep = ",", header = 0, index_col = False)
Y = pd.read_csv(G.dir_data + y_data_files[0], sep = ",", header = 0, index_col = False)

for f in x_data_files:
    if f is not x_data_files[0]:
        temp = pd.read_csv(G.dir_data + f, sep = ",", header = 0, index_col = False)
        print "Acquiring %s ..." % f
        X = pd.merge(X, temp, left_index = True, right_index = True)

print "X has %d observations with %d variables" % X.shape
print "Y has %d observations" % len(Y)

## split data set into train, test, validation (0) ----
is_train = np.random.uniform(0, 1, len(X)) < G.train_ratio
Xtrain, Xtest = X[is_train == True], X[is_train == False]
Ytrain, Ytest = Y[is_train == True], Y[is_train == False]

## RandomFroest Training -------------------------------
print "Training Random Forest"
features = X.columns[:100]
clf = RandomForestClassifier(n_estimators = G.ntrees,
							 n_jobs = G.parall["ncores"], 
                             max_depth = None, min_samples_split=100, random_state=123)

## Fitting ---------------------------------------------
clf.fit(Xtrain[features], Ytrain)
preds = clf.predict(Xtest[features])
## Test performance -------------------------------------
pd.crosstab(Ytest, preds, rownames = ['actual'], colnames = ['preds'])
print pd.crosstab(Ytest, preds, rownames = ['actual'], colnames = ['preds'])

print "** end_datetime: %s" % datetime.datetime.now()
