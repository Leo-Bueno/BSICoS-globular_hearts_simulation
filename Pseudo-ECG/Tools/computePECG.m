function [ pECG ] = computePECG( H , E )
% pECG = computePECG( H , E )
% where:
% pECG is [ I , II , III , aVR , aVL , aVF , V1 , V2 , V3 , V4 , V5 , V6]

  BSP = NaN( size( H.triG , 3 ) , size( E , 1 ) );
  for e = 1:size( E , 1 )
    if e == 4, continue; end
    r  = bsxfun( @plus , H.triCENTER , -E(e,:) );
    r2 = sum( r.^2 ,2);

%     d1_r = bsxfun( @rdivide , r , realpow( r2 , 3/2) );
    d1_r = bsxfun( @times , r , sqrt( r2.^( -3 ) ) );
    d1_r = bsxfun( @times , H.triVOL , d1_r );

    
    

    try
        BSP(:,e) = vec( d1_r(:).' * reshape( H.triG , [], size( H.triG ,3) ) );
    catch
        for t = 1:size( H.triG , 3 )
%             BSP(t,e) = sum( dot( d1_r , H.triG(:,:,t) , 2 ) );
            BSP(t,e) = d1_r(:).' * vec( H.triG(:,:,t) );
        end
    end
    
  end


  
  I   = BSP(:,1) - BSP(:,2);
  II  = BSP(:,3) - BSP(:,2);
  III = BSP(:,3) - BSP(:,1);

  
  BSP = bsxfun( @plus , BSP , -mean( BSP(:,[1 2 3]) ,2) );
  
  aVR = BSP(:,2 ) *3/2;
  aVL = BSP(:,1 ) *3/2;
  aVF = BSP(:,3 ) *3/2;
  V1  = BSP(:,5 );
  V2  = BSP(:,6 );
  V3  = BSP(:,7 );
  V4  = BSP(:,8 );
  V5  = BSP(:,9 );
  V6  = BSP(:,10);

  pECG = [ I , II , III , aVR , aVL , aVF , V1 , V2 , V3 , V4 , V5 , V6 ];

end

function x=vec(x)
x=x(:);
end