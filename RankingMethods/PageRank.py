#!/usr/bin/python2
# -*- coding: utf-8 -*-
from numpy import zeros, ones, multiply, outer, dot


def pagerank(H):
    n = len(H)
    for i in range(n):
        H[i] = [x / float(sum(H[i])) for x in H[i]]

    w = zeros(n)
    rho = 1. / n * ones(n)
    for i in range(n):
        if multiply.reduce(H[i] == zeros(n)):
            w[i] = 1
    newH = H + outer(1. / n * w, ones(n))

    theta = 0.85
    G = theta * newH + (1 - theta) * outer(1. / n * ones(n), ones(n))
    print 'initial pagerank scores:'
    print rho
    for j in range(10):
        rho = dot(rho, G)
        print 'pagerank scores after %d iteration:' % (j + 1)
        print rho


print """Enter adjacency matrix for the pages, example:
\
        [[0,0,1,0],[0,0,1,0],[0,0,0,1],[1,1,1,0]]
"""
pagerank(input())
