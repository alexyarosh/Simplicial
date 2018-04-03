using Simplicial
using Base.Test

C1 = CombinatorialCode([[], [1], [1,2], [2,3]])
C2 = CombinatorialCode([[], [1], [1,2],[2,3], [2,1]], signed=false)

@test C1 == C2

CF1 = [PseudoMonomial([1,3],[]), PseudoMonomial([3],[2]), PseudoMonomial([2],[1,3])]

@test CF1 == canonical_form(C1)

C3 = CombinatorialCode([[],[1],[1,2],[2,3],[2]])
C4 = CombinatorialCode([[],[1],[1,2],[2,3],[1,2,3]])

@test intersection_completion(C1) == C3
@test union_completion(C2) == C4

K0 = SimplicialComplex([])

@test isvoid(K0)

K1 = SimplicialComplex([[1,2],[2,3]])
K2 = SimplicialComplex(C1)

@test dim(K1) == 1
@test K1 == K2

K5 = SimplicialComplex([[1,2,3,4],[2,3,4,5]])

@test dim(K5) == 3

D = SimplicialComplex([[1,2,4],[2,4,5],[1,3,4],[3,4,5]])

@test D == del(K5,[2,3])

L = SimplicialComplex([[4,1],[4,5]])

@test L == link(K5, [2,3])

G1 = polar_complex(C1)
G2 = polar_complex(C2)
G = SimplicialComplex([[-1,-2,-3],[1,-2,-3],[1,2,-3],[-1,2,3]])

@test G1 == G
@test G1 != G2
