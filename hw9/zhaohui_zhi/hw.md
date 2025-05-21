# Homework 

## Zhaohui Zhi

### P1
As in [main.jl](main.jl)
### P2

First, we need to turn off the `set_silent` for Model, obtain its log, as:

```
presolving (35 rounds: 35 fast, 28 medium, 26 exhaustive):
 30 deleted vars, 51 deleted constraints, 23 added constraints, 0 tightened bounds, 0 added holes, 20 changed sides, 104 changed coefficients
 0 implications, 536 cliques
presolved problem has 89 variables (89 bin, 0 int, 0 impl, 0 cont) and 299 constraints
     59 constraints of type <knapsack>
     97 constraints of type <setppc>
     72 constraints of type <and>
      5 constraints of type <linear>
     66 constraints of type <logicor>
Presolving Time: 0.04
transformed 1/38 original solutions to the transformed problem space

 time | node  | left  |LP iter|LP it/n|mem/heur|mdpt |vars |cons |rows |cuts |sepa|confs|strbr|  dualbound   | primalbound  |  gap   | compl. 
  0.3s|     1 |     0 |  2917 |     - |    25M |   0 |  89 | 299 | 304 |   0 |  0 | 107 |  42 |-1.014372e+01 |-6.061349e+00 |  67.35%| unknown
  0.3s|     1 |     0 |  2944 |     - |    25M |   0 |  89 | 299 | 306 |   2 |  1 | 107 |  42 |-1.004818e+01 |-6.061349e+00 |  65.77%| unknown
  0.3s|     1 |     0 |  2971 |     - |    25M |   0 |  89 | 301 | 311 |   7 |  2 | 109 |  42 |-9.989143e+00 |-6.061349e+00 |  64.80%| unknown
  0.3s|     1 |     0 |  2998 |     - |    25M |   0 |  89 | 303 | 314 |  10 |  3 | 111 |  42 |-9.947973e+00 |-6.061349e+00 |  64.12%| unknown
  0.3s|     1 |     0 |  3034 |     - |    25M |   0 |  89 | 305 | 317 |  13 |  4 | 113 |  42 |-9.838727e+00 |-6.061349e+00 |  62.32%| unknown
  0.3s|     1 |     0 |  3044 |     - |    25M |   0 |  89 | 306 | 316 |  13 |  4 | 115 |  42 |-9.832915e+00 |-6.061349e+00 |  62.22%| unknown
  0.4s|     1 |     0 |  3080 |     - |    25M |   0 |  89 | 306 | 320 |  17 |  5 | 115 |  42 |-9.734564e+00 |-6.061349e+00 |  60.60%| unknown
  0.4s|     1 |     0 |  3100 |     - |    25M |   0 |  89 | 307 | 323 |  20 |  6 | 116 |  42 |-9.686159e+00 |-6.061349e+00 |  59.80%| unknown
  0.4s|     1 |     0 |  3112 |     - |    26M |   0 |  89 | 307 | 325 |  22 |  7 | 116 |  42 |-9.634154e+00 |-6.061349e+00 |  58.94%| unknown
  0.4s|     1 |     0 |  3149 |     - |    27M |   0 |  89 | 307 | 327 |  24 |  8 | 116 |  42 |-9.497058e+00 |-6.061349e+00 |  56.68%| unknown
  0.4s|     1 |     0 |  3171 |     - |    27M |   0 |  89 | 309 | 331 |  28 |  9 | 118 |  42 |-9.321017e+00 |-6.061349e+00 |  53.78%| unknown
  0.4s|     1 |     0 |  3198 |     - |    27M |   0 |  89 | 310 | 335 |  32 | 10 | 119 |  42 |-8.487344e+00 |-6.061349e+00 |  40.02%| unknown
  0.4s|     1 |     0 |  3214 |     - |    27M |   0 |  89 | 310 | 326 |  32 | 10 | 120 |  42 |-7.150712e+00 |-6.061349e+00 |  17.97%| unknown
  0.4s|     1 |     0 |  3214 |     - |    27M |   0 |  89 | 311 | 293 |  32 | 10 | 121 |  42 |-7.150712e+00 |-6.061349e+00 |  17.97%| unknown
  0.4s|     1 |     0 |  3217 |     - |    27M |   0 |  89 | 296 | 284 |  34 | 11 | 121 |  42 |-6.308960e+00 |-6.061349e+00 |   4.09%| unknown
 time | node  | left  |LP iter|LP it/n|mem/heur|mdpt |vars |cons |rows |cuts |sepa|confs|strbr|  dualbound   | primalbound  |  gap   | compl. 
  0.4s|     1 |     0 |  3217 |     - |    27M |   0 |  89 | 298 | 270 |  34 | 11 | 123 |  42 |-6.308960e+00 |-6.061349e+00 |   4.09%| unknown
  0.4s|     1 |     0 |  3220 |     - |    27M |   0 |  89 | 294 | 271 |  35 | 12 | 123 |  42 |-6.061349e+00 |-6.061349e+00 |   0.00%| unknown
  0.4s|     1 |     0 |  3220 |     - |    27M |   0 |  89 | 294 | 271 |  35 | 12 | 123 |  42 |-6.061349e+00 |-6.061349e+00 |   0.00%| unknown

SCIP Status        : problem is solved [optimal solution found]
Solving Time (sec) : 0.38
Solving Nodes      : 1 (total of 4 nodes in 4 runs)
Primal Bound       : -6.06134935056922e+00 (39 solutions)
Dual Bound         : -6.06134935056922e+00
Gap                : 0.00 %
```

Analyzing that we could find:

1. **Significant effect in the preprocessing phase**: A large number of variables and constraints are deleted or fixed, indicating that the problem structure may be suitable for preprocessing. We need to strengthen the preprocessing strategy, such as increasing the strength or frequency of certain preprocessing methods.

2. **Symmetry processing**: The log mentions "symmetry computation found 3 generators". We may need to enable or adjust related parameters.

3. **Heuristic method**: The rens and rounding are disabled, but the log shows that the solution is found after multiple restarts, so we may need to enable some heuristics such as rins or strengthen the settings of subnlp.

4. **Cutting plane strategy**: The log shows that many cliques (such as 536 clqs inthe end) were generated in the preprocessing stage. It may be helpful to enable clique cuts, or adjust their frequency. In addition, the Gomory cut may need to be set more aggressively, such as more frequently applied.

So finally given above analysis and refer to the home page of SCIP, we select the parameters such as:

``` Julia
paras = Dict([
    # 核心控制
    ("presolving/maxrestarts", 0),            # 禁用自动重启
    ("propagating/obbt/freq", -1),            # 关闭耗时OBBT传播
    ("constraints/countsols/collect", 1),     # 增强解计数分析
    
    # 对称性处理
    ("propagating/symmetry/priority", 10000),                   # 启用强对称处理
    ("propagating/symmetry/freq", 10),            
    
    # 分支策略优化
    ("branching/relpscost/priority", 5000),   # 可靠性伪成本分支
    ("branching/vanillafullstrong/idempotent", false),# 完全强分支缓存
    
    # 割平面强化
    ("separating/clique/freq", 10),           # 启用clique割
    ("separating/zerohalf/freq", 5),          # 零半割加强
    ("separating/gomory/freq", 3),            # 更积极的Gomory割
    
    # 启发式优化
    ("heuristics/undercover/freq", 20),       # 覆盖式启发
    ("heuristics/proximity/freq", 15),        # 邻近搜索
    ("heuristics/shifting/freq", 10),         # 增强位移启发
    
    # LP求解优化
    # ("lp/resolvealgorithm", "b"),             # 屏障法解初始LP
    ("lp/threads", 2),                        # 限制LP线程避免争抢
    
    # 数值稳定性
    ("numerics/feastol", 1e-6),               # 恢复默认精度
    ("numerics/lpfeastolfactor", 1e-3)              # 加强LP精度
])
```