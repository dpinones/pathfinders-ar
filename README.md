Jump Point Search in Cairo
==============
![banner](https://user-images.githubusercontent.com/58611754/193924642-e6404c87-20f8-4934-acff-9f9c868342e8.png)
------------
Introduction
------------
This project was developed for the MatchBoxDAO Hackathon, the idea is to develop in Cairo an algorithm that solves the path search problem for a map represented in 2D grids.
The map may contain obstacles, furthermore we assume that the movement in the squares is bidirectional with a uniform movement cost.

It is currently uploaded to Testnet and you can test how it works by entering the [following link](), in this example we will be able to set obstacles in a map of n*m that will later work as input in the algorithm. Once finished, the jump points that were chosen to reach the goal will be displayed.

How to use it?
------------


Performance examples
------------


Next steps
------------
Given that we had a limited time to understand, program and show the algorithm, things were pending that we would like to develop in the future:
- Optimize the JPS algorithm currently implemented (look for improvements in terms of data structure management, variables, steps)
- Implement different path search algorithms such as BFS, A*, Dijkstra, HPA*, etc.

Useful links
------------
The implementation of the presented algorithm was based on the paper [Online Graph Pruning for Pathfinding on Grid Maps](https://web.archive.org/web/20140310055234/http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf) by Daniel Harabor and Alban Grastien.

We also mention Nathan Witmer that thanks to his [article](https://web.archive.org/web/20140310022652/https://zerowidth.com/2013/05/05/jump-point-search-explained.html) we were able to have a first approach to the algorithm in a friendly way.
