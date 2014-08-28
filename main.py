## Import modules -----------------
import sys
import os
import numpy as np
import pandas as pd
## Machine Learning ---------------
from sklearn.ensemble import RandomForestRegressor as RFR


#print(os.getcwd())
class G(object):
    root_dir = "/Users/beingzy/Documents/stock_trade/"
    data_dir = "/Users/beingzy/Documents/stock_trade/data/"
    data_util_rate = {'dev': .1, 'prod': .2} # 20% data to develop the code
    data_train_rate = .7 # split the data set into 70% for training & 30% for testing & 0% for validation

run_type = 'dev'
#print G.data_dir + 'x.txt'
print "Loading X data...\n"

xdf         = pd.read_csv(G.data_dir + 'x.txt', sep = " ", header = None, index_col = False)
xdf         = xdf.drop(5, axis=1, inplace=False)
xdf.columns = ["trade_size", "bid_price", "ask_price", "bid_size", "ask_size"]

print "%s had been loaded with successfully" % 'xdf'
print "Loading y data...\n"

ydf         = pd.read_csv(G.data_dir + 'y.txt', sep = " ", header = 0, index_col = False)
ydf.columns = ['trad_price']

print "%s had been loaded with successfully" % 'ydf'

# Retain G.dev_ratio of observation for develop the code
is_dev   = np.random.uniform(0, 1, len(ydf)) < G.data_util_rate[run_type]
x, y = xdf[is_dev == True], ydf[is_dev == True]
y['is_train'] = np.random.uniform(0, 1, len(y)) < G.data_train_rate

print "Spliting data into train(70%) and test(30%)\n"
x_train, x_test = x[y['is_train'] == True], x[y['is_train'] == False]
y_train, y_test = y[y['is_train'] == True], y[y['is_train'] == False]
