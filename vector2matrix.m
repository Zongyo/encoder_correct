function matrix = vector2matrix(vector,sp_num)
    row = size(vector,1)/sp_num;
    col = sp_num;
    matrix=zeros(row,col);
    for i = 1: col
        for j = 1:row
            matrix(j,i) = vector(j+(i-1)*row);
        end
    end
end