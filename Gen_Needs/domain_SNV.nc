CDF       
      nv        ni        nj              
Created_by        cxu    
Created_on        Fri Dec 16 11:30:56 2022             xc                    	long_name         longitude of grid cell center      units         degrees_east   bounds        xv          �   yc                    	long_name         latitude of grid cell center   units         degrees_north      bounds        yv          �   xv                        	long_name         longitude of grid cell vertices    units         degrees_east         �   yv                        	long_name         latitude of grid cell vertices     units         degrees_north            �   mask                  	long_name         land domain mask   
coordinate        xc yc      note      unitless   comment       70=ocean and 1=land, 0 indicates that cell is not active         �   frac                  	long_name         $fraction of grid cell that is active   
coordinate        xc yc      units         unitless   filter1       =error if frac> 1.0+eps or frac < 0.0-eps; eps = 0.1000000E-11      filter2       Jlimit frac to [fminval,fmaxval]; fminval= 0.1000000E-02 fmaxval=  1.000000          �   area                  	long_name         $area of grid cell in radians squared   
coordinate        xc yc      units         radians2        �@o��\(��@A��
=p�@o��\(��@o��\(��@o��\(��@o��\(��@A��
=p�@A��
=p�@B�
=p�@B�
=p�   ?�      ?�      