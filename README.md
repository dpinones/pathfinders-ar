Jump Point Search in Cairo
==============
![banner](https://user-images.githubusercontent.com/58611754/193924642-e6404c87-20f8-4934-acff-9f9c868342e8.png)
------------
Introduction
------------
This project was developed for the MatchBoxDAO Hackathon, the idea is to develop in Cairo an algorithm that solves the path search problem for a map represented in 2D grids.
The map may contain obstacles, furthermore we assume that the movement in the squares is bidirectional with a uniform movement cost.

It is currently uploaded to Testnet and you can test how it works by entering the [following link](https://dpinones.github.io/pathfinding-visualizer/) (credits to [Rohith](https://github.com/rohithaug)), in this example we will be able to set obstacles in a map of n*m that will later work as input in the algorithm. Once finished, the jump points that were chosen to reach the goal will be displayed.

How to use it?
------------
1. Using view function [Cairo Contract](https://goerli.voyager.online/contract/0x04cdb56f4057b6ccbb2c859fccd0abce3983008365bdfbffd9b27f957946fce6#readContract).
```
The position (0,0) on the map starts at the top left, positions increase in the opposite direction

start_x: int
start_y: int
end_x: int 
end_y: int
grids: int[] // Example: [0, 0 , 0, 1, 1, ..., 0],  0 = walkable, 1 = obstacle
width: int // This value determines how many divisions the grid array will have.
height: int 
```
Input example in [test](https://github.com/dpinones/pathfinders-ar/blob/main/tests/jps_test.cairo#L382)

2. Using the web app in [link](https://dpinones.github.io/pathfinding-visualizer/).

![image](https://user-images.githubusercontent.com/58611754/196833523-5a07d662-11c3-4dc2-802f-b5f37ecfcd6d.png)

Performance examples
------------

The following grid shows approximate values just to get an idea of the response performance as the size of the map grows. The maps were generated in the visualizer that we mentioned earlier.

------------------------------------------------------------------------------------------------------------
|Map dimension|Clean map|Random maze|Recursive division maze|Vertical division maze|Horizontal division maze|
| --- | --- | --- | --- | --- | --- |
| 10 x 10 | 1.80s | 2.23s | 1.86s | 3.17s | 1.82s | 
| 15 x 15 | 4.12s | 3.95s | 3.36s | 2.98s | 2.85s |
| 20 x 20 | 4.65s | 3.89s | 7.45s | 9.04s | 8.19s |
| 25 x 25 | 11.00s | 8.92s | 9.82s | 8.60s | 8.35s ||
| 30 x 30 | 18.59s | 12.26s | 8.97s | 10.47s | 13.05s |

Next steps
------------
Given that we had a limited time to understand, program and show the algorithm, things were pending that we would like to develop in the future:
- Optimize the JPS algorithm currently implemented (look for improvements in terms of data structure management, variables, steps).
- From a map of size 25 *25 we notice that the contract cannot solve the problem, due to the amount of resources consumed by the algorithm.
- Implement different path search algorithms such as BFS, A*, Dijkstra, HPA*, etc.

Useful links
------------
The implementation of the presented algorithm was based on the paper [Online Graph Pruning for Pathfinding on Grid Maps](https://web.archive.org/web/20140310055234/http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf) by Daniel Harabor and Alban Grastien.

We also mention Nathan Witmer that thanks to his [article](https://web.archive.org/web/20140310022652/https://zerowidth.com/2013/05/05/jump-point-search-explained.html) we were able to have a first approach to the algorithm in a friendly way.
