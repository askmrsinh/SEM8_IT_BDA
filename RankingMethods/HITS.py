#!/usr/bin/python2
# -*- coding: utf-8 -*-
from numpy import dot, transpose, ones


def hits(A):
    iterations = 6
    n = len(A)
    Au = dot(transpose(A), A)
    Hu = dot(A, transpose(A))
    a = ones(n)
    h = ones(n)
    print 'initial authority and hub scores:'
    print a, h
    for j in range(iterations):
        a = dot(a, Au)
        a = a / sum(a)
        h = dot(h, Hu)
        h = h / sum(h)
        print 'authority and hub scores after %d iteration:' % (j + 1)
        print a, h


print """Enter adjacency matrix for the pages, example:
\
        [[0,0,1,0],[0,0,1,0],[0,0,0,1],[1,1,1,0]]
"""
hits(input())
