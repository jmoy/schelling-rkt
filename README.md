Simulate Schelling's segregation model
as described on Sargent and Stachurski's site
http://quant-econ.net/py/schelling.html

Implementation language: Racket. 

## The Problem

This section is entirely quoted from Sargent-Stachurski.

### Set Up

Suppose we have two types of people: orange people and green people

For the purpose of this lecture, we will assume there are 250 of each type

These agents all live on a single unit square

The location of an agent is just a point (x,y), where 0 < x,y < 1

### Preferences

We will say that an agent is happy if half or more of her 10 nearest neighbors are of the same type

Here ‘nearest’ is in terms of Euclidean distance

An agent who is not happy is called unhappy

An important point here is that agents are not averse to living in mixed areas

They are perfectly happy if half their neighbors are of the other color

### Behavior

Initially, agents are mixed together (integrated)

In particular, the initial location of each agent is an independent draw from a bivariate uniform distribution on S=(0,1)<sup>2</sup>.

Now, cycling through the set of all agents, each agent is now given the chance to stay or move

We assume that each agent will stay put if they are happy and move if unhappy

The algorithm for moving is as follows

1. Draw a random location in S
2. If happy at new location, move there
3. Else, go to step 1

In this way, we cycle continuously through the agents, moving as required

We continue to cycle until no one wishes to move

## Problem in Sargent-Stachurski implementation

In the [implementation](https://github.com/QuantEcon/QuantEcon.py/blob/46ef25fbb8b28d7d8f5e345edc6208c899c24bfc/solutions/schelling_solutions.ipynb) currently (Nov. 2015) on Sargent-Stachurski, the
model is not implemented as described above. Agents have a preference not for homogeneity but for beign close to others of their own color. Once the model as described above is implemented the fast convergence found by S.-S. seems to disapper.
