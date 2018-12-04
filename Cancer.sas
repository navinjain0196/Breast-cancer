proc import datafile = '/home/navinjain01960/my_courses/Breast cancer.csv'
 out = work.cancer
 dbms = CSV
 replace
 ;
run;

title1 "LDA";
proc discrim pool=YES data=transform crossvalidate;
	class diagnosis;
	var radius_mean	texture_mean	perimeter_mean	area_mean	smoothness_mean	compactness_mean	concavity_mean
	concavepoints_mean	symmetry_mean	fractal_dimension_mean	logradius_se	texture_se	perimeter_se	
	area_se	smoothness_se	compactness_se	concavity_se	concavepoints_se	symmetry_se	fractal_dimension_se	
	radius_worst	texture_worst	perimeter_worst	logarea_worst	smoothness_worst	compactness_worst	concavity_worst	
	logconcavepoints_worst	symmetry_worst	fractal_dimension_worst ;
	priors proportional;
run;

title "KNN";
proc discrim data=transform method=npar k=5 crossvalidate ;
  class diagnosis ;
  var radius_mean	texture_mean	perimeter_mean	area_mean	smoothness_mean	compactness_mean	concavity_mean
	concavepoints_mean	symmetry_mean	fractal_dimension_mean	logradius_se	texture_se	perimeter_se	
	area_se	smoothness_se	compactness_se	concavity_se	concavepoints_se	symmetry_se	fractal_dimension_se	
	radius_worst	texture_worst	perimeter_worst	logarea_worst	smoothness_worst	compactness_worst	concavity_worst	
	logconcavepoints_worst	symmetry_worst	fractal_dimension_worst ;
 priors proportional ;
run;

 data transform;
      set work.cancer;
      logradius_se=LOG(1+radius_se) ;
      logarea_worst=LOG(1+area_worst) ;
      logconcavepoints_worst	=log(1+concavepoints_worst)  ;
      
   run;
   

title "Logistic regression";
proc logistic data=work.cancer descending ;

model diagnosis = 	radius_mean	texture_mean	perimeter_mean	area_mean	smoothness_mean	compactness_mean	concavity_mean
	concavepoints_mean	symmetry_mean	fractal_dimension_mean	radius_se	texture_se	perimeter_se	
	area_se	smoothness_se	compactness_se	concavity_se	concavepoints_se	symmetry_se	fractal_dimension_se	
	radius_worst	texture_worst	perimeter_worst	area_worst	smoothness_worst	compactness_worst	concavity_worst	
	concavepoints_worst	symmetry_worst	fractal_dimension_worst
/ Selection= backward sls= 0.05 ctable;
roc;
score data= work.cancer out= cancer1 ; 
run ; 

Title1 'Fitting a classification tree to Cancer data';
proc hpsplit DATA=work.cancer cvmethod=random(10) seed=123
           intervalbins=5000 cvmodelfit plots(only)=cvcc;
Class diagnosis;
Model diagnosis =radius_mean	texture_mean	perimeter_mean	area_mean	smoothness_mean	compactness_mean	concavity_mean
	concavepoints_mean	symmetry_mean	fractal_dimension_mean	radius_se	texture_se	perimeter_se	
	area_se	smoothness_se	compactness_se	concavity_se	concavepoints_se	symmetry_se	fractal_dimension_se	
	radius_worst	texture_worst	perimeter_worst	area_worst	smoothness_worst	compactness_worst	concavity_worst	
	concavepoints_worst	symmetry_worst	fractal_dimension_worst ;
grow gini;
run;

Title1 'Fitting a classification tree to BreastCancer data';
Title2 'Tree with 7terminal nodes';
proc hpsplit DATA=work.cancer cvmethod=random(10) seed=123 cvmodelfit
intervalbins=5000;
class diagnosis;
Model diagnosis = radius_worst	texture_worst concavepoints_worst concavepoints_mean texture_mean concavity_mean;
grow gini;
prune costcomplexity (leaves=7);
run;

