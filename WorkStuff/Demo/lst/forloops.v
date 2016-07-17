// for == repeat HW

always @(A or B)
begin
	G = 0;
	for (I = 0; I < 4; I = I + 1)
	begin
		F[I] = A[I] & B[3-I];
		G = G ^ A[I];
	end
end
