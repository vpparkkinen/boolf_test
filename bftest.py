import os
import csv
#import boolformer as bf
import numpy as np
import pandas as pd
import torch

class BFtest:
    def __init__(self, model, data, outcome):
        self.model = model
        self.data = data
        self.inputs = self.data.drop(outcome, axis = 1)
        self.outcome = self.data[outcome]
        self.ipcols = list(self.inputs)
        self.connsops = ["+", "*", "!"]
        self.tra_vals = self.ipcols + self.connsops
        self.out_vars = ["x_" + str(i) for i in range(len(self.ipcols))]
        self.out_connsops = ["or", "and", "not"]
        self.tra_keys = self.out_vars + self.out_connsops
        self.tra_dict = dict(zip(self.tra_keys, self.tra_vals))

    def fit(self):
        a = self.model.fit(self.inputs.to_numpy(), self.outcome.to_numpy(), verbose=False, beam_size=10, beam_type="search")[0]
        print(type(a[0]))
        a = a[0].infix()
        #print(a)
        #return a[0].infix()
        out = translate(a, self.tra_dict)
        return out

    @staticmethod
    def translate(txt, cdict):
        for key, value in cdict.items():
            txt = txt.replace(key, value)
        return txt

wd = os.getcwd()
boolformer_model = torch.load("../../boolformer_noisy.pt")
ip = pd.read_csv("../../data/dat1.csv", sep = ";")

nfil = len([1 for x in list(os.scandir("../../data")) if x.is_file()])

res = []
for i in range(1, nfil+1):
    ip = pd.read_csv("../../data/dat" + str(i) + ".csv", sep = ";")
    mf = BFtest(boolformer_model, ip, "A")
    res.append(mf.fit())

np.savetxt("../../ress.txt", res, delimiter="\n", fmt="%s")
