%% function to averange the rol of matrix
function vector = matrix2vector(matrix)
row = size(matrix,1);
col = size(matrix,2);
vector = zeros(row,1);
for i = 1:col
    vector=vector + matrix(1:end,i);
end
vector = vector/col;
end