function make(var,kernel,corlength,homogen, symmetry, filename)
% This make file compiles mexBBFMM3D and creates the mex function
% Creates text file kernelfun.hpp from input
% This file does not require modification for the mexBBFMM3D package

% convert kernel to C readable format
var = char(var);

ckernel = ccode(kernel);

% Pass the Kernel to kernelfun.hpp
fid = fopen('./BBFMM3D/include/kernelfun.hpp','w+');
fprintf(fid,'class myKernel: public H2_3D_Tree {\n');
fprintf(fid,'public:\n');
fprintf(fid,'    myKernel(double L, int level, int n,  double epsilon, int\n');
fprintf(fid,'       use_chebyshev):H2_3D_Tree(L,level,n, epsilon, use_chebyshev){};\n');
fprintf(fid,'    virtual void setHomogen(string& kernelType,doft*dof) {\n');
fprintf(fid,'       homogen = %d;\n', homogen);
fprintf(fid,'       symmetry = %d;\n', symmetry);
fprintf(fid,'       dof->f = 1;\n');
fprintf(fid,'       dof->s = 1;\n');
fprintf(fid,'       kernelType = "myKernel";}\n');
fprintf(fid,'       virtual void EvaluateKernel(vector3 fieldpos, vector3 sourcepos,\n');
fprintf(fid,'                               double *K, doft *dof) {\n');
fprintf(fid,'    double lx = %f;\n',corlength);
fprintf(fid,'    double ly = %f;\n',corlength);
fprintf(fid,'    double lz = %f;\n',corlength);
fprintf(fid,'    double rx = (sourcepos.x - fieldpos.x)*(sourcepos.x - fieldpos.x)*(1.0/lx)*(1.0/lx);\n');
fprintf(fid,'    double ry = (sourcepos.y - fieldpos.y)*(sourcepos.y - fieldpos.y)*(1.0/ly)*(1.0/ly);\n');
fprintf(fid,'    double rz = (sourcepos.z - fieldpos.z)*(sourcepos.z - fieldpos.z)*(1.0/lz)*(1.0/lz);\n');
fprintf(fid,'    double %s = sqrt( rx + ry + rz );\n',var);
fprintf(fid,'    double t0;         //implement your own kernel on the next line\n');
fprintf(fid,'    %s\n',ckernel);
fprintf(fid,'    *K =  t0;\n');
fprintf(fid,'    }\n');
fprintf(fid,'};\n');
fclose(fid);

% this file will call mexBBFMM3D.cpp
src1 = './BBFMM3D/src/H2_3D_Tree.cpp';
src2 = './BBFMM3D/src/kernel_Types.cpp';

disp(pwd)
eigenDIR = './eigen/';
fmmDIR = './BBFMM3D/include/';
mex('-O','./mexFMM3D.cpp',src1, src2,'-largeArrayDims',['-I',eigenDIR],['-I',fmmDIR],...
    '-llapack', '-lblas',...
    '-L/usr/local/lib', '-lrfftw', '-lfftw', '-lm','-g',  ...
    '-I/usr/local/include',...
    '-I.', '-output',filename)
disp('mex compiling is successful!')
end

%    '-I/opt/intel/Compiler/11.1/084/Frameworks/mkl/include/fftw',...
