
type GradedPoset
  dimensions::Array{Int,1} # this is the list of dimensions of the graded poset. This can not be smaller then -1 (corresponding to the empty set)
  dim::Int   # the maximun of dimensions
  Nelements::Array{Int,1}  # total number of facets in teach dimension
  boundaries::Array{Array{Array{Int,1},1},1}   # this is a list of lists each list enumerates the boundary one step down
  negativesigns::Array{Array{BitArray,1},1}
# here boundaries[i][j] is an array of boundaries of the j-th element in i-th dimension
# here negativesigns[i][j] is an array that indicates if the appropriate boundaary has negative signs
"This is the constructor for theGradedPoset type from the  DirectedComplex type.
The way it works, it starts at the top sequences, and iteratively takes the subsequences
"
   function GradedPoset(D::DirectedComplex,verbose=false)
   dimensions=collect(-1:D.dim); Ndimensions=length(dimensions);
   boundaries=Array{Array{Array{Int,1},1},1}(Ndimensions); #
   negativesigns=Array{Array{BitArray,1},1}(Ndimensions);
   for i=1:Ndimensions; boundaries[i]=[]; negativesigns[i]=[] end
   Nelements=ones(Int,Ndimensions);
   # set everything for the 0-dimensional things
   Nelements[2]=length(D.vertices);
   negativesigns[2]=Array{BitArray,1}(Nelements[2]);
   boundaries[2]=Array{Array{Int,1},1}(Nelements[2]);
  for i=1:Nelements[2]; negativesigns[2][i]=falses(1); boundaries[2][i]=ones(Int,1);end
# For now we assume that the directed complex is pure, i.e. all the maximal sequences have the same length
 dim =D.dimensions[1]; if !all(D.dimensions.==dim); error(" This function currently can only handle pure complexes"); end
 currentsequences=copy(D.facets);
  for curdimecounter=Ndimensions:-1:3
    currentlength=curdimecounter-1;
    Nelements[curdimecounter]=length(currentsequences)
    boundaries[curdimecounter]=Array{Array{Int,1},1}(Nelements[curdimecounter]);
    negativesigns[curdimecounter]=Array{BitArray,1}(Nelements[curdimecounter]);
    boundarysequences=Array{Array{Int,1},1}();
      for m=1: length(currentsequences)
        boundaries[curdimecounter][m]=zeros(Int, length(currentsequences[m]));
        negativesigns[curdimecounter][m]=falses(length(currentsequences[m]));
        # here we produce the subsequences of currentsequences[m]
        subsequences=collect(combinations(currentsequences[m],currentlength-1));
        hasnegativesign=iseven(currentlength);
            for i=1:currentlength
                was_encountered_before=false;
            for s=1:length(boundarysequences)
               if boundarysequences[s]==subsequences[i];
                    was_encountered_before=true
                    ith_place=s
                    break
               end # if
            end   #for s=1:length(boundarysequences)
              if !was_encountered_before
                push!(boundarysequences,subsequences[i]); # the actual sequence
                ith_place=length(boundarysequences);
              end
      boundaries[curdimecounter][m][i]=ith_place;
      negativesigns[curdimecounter][m][i]=hasnegativesign;
      hasnegativesign=!hasnegativesign;
    end # for i=1:currentlength
end #   for m=1: length(currentsequences)

# this is diagnostic printing:
if verbose
 print_with_color(:red, "in length $(currentlength)"); println(" there are $(Nelements[curdimecounter]) sequences:")
  for m=1: length(currentsequences); print("sequence $m : ");println(currentsequences[m]);end
   println("with the following boundary sequences:")
for m=1: length(boundarysequences); print_with_color(:blue, "sequence $m : "); println(boundarysequences[m]);end
end




currentsequences=boundarysequences;
end   # for currentdimensioncounter=Ndimensions:-1:2
   new(dimensions,D.dim, Nelements,boundaries,negativesigns)
  end
end





function BoundaryOperator(P::GradedPoset,k)::SparseMatrixCSC{Int64,Int64}
assert(issubset([k, k-1],P.dimensions))
k_ind=findfirst(P.dimensions.==k)
d=spzeros(Int, P.Nelements[k_ind-1],P.Nelements[k_ind]);

for m=1:P.Nelements[k_ind];
    for j=1:length(P.boundaries[k_ind][m])
      d[P.boundaries[k_ind][m][j],m]=(P.negativesigns[k_ind][m][j])? -1 : 1 ;
    end
end
return d
end




"""
beta=BettiNumbers(D::DirectedComplex)
This function returns the Betti numbers of the reduced (!!) homology of a (so far only pure) directed complex

This is a very crude way to compute directed homology -- this does not use any tricks,
just the definition and the built-in rank function that may fail to work properly on large enough matrices.
Use with caution. Works as prescribed on small enough complexes.

Here the length of beta is equal to P.dim+1,
beta[1] is 0-th Betti number  and beta[P.dim+1] is the P.dim-dimensional Betti number


"""
function BettiNumbers(D::DirectedComplex)::Vector{Int}
         P=GradedPoset(D);
         beta=zeros(Int,P.dim+1);

         rank_d_n=rank(full(BoundaryOperator(P,0)));
         for n=0:P.dim;
             dim_C_n= P.Nelements[n+2];
             if n<P.dim
                rank_d_nplus1=rank(full(BoundaryOperator(P,n+1)));
                beta[n+1]=dim_C_n-rank_d_n - rank_d_nplus1
                rank_d_n=rank_d_nplus1
             else
                  beta[P.dim+1]=dim_C_n-rank_d_n
             end
          end
return beta
end