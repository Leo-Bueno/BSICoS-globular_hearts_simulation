function [varargout] = meshVolume( M , varargin )
  
  P1 = []; P2 = []; P3 = []; P4 = [];
  %precomputed nodes coordinates
  if size( M.tri,2) > 0
    P1 = M.xyz( M.tri(:,1) ,:); P1(:,end+1:3) = 0;
  end
  if size( M.tri,2) > 1
    P2 = M.xyz( M.tri(:,2) ,:); P2(:,end+1:3) = 0;
  end
  if size( M.tri,2) > 2
    P3 = M.xyz( M.tri(:,3) ,:); P3(:,end+1:3) = 0;
  end
  if size( M.tri,2) > 3
    P4 = M.xyz( M.tri(:,4) ,:); P4(:,end+1:3) = 0;
  end


  cross = @(a,b)[ a(:,2).*b(:,3) - a(:,3).*b(:,2) ,...
                  a(:,3).*b(:,1) - a(:,1).*b(:,3) ,...
                  a(:,1).*b(:,2) - a(:,2).*b(:,1) ];
  
  L1 = []; L3 = []; L4 = [];
  function get_Ls, if ~isempty( L1 ), return; end
    if M.celltype >= 3
      L1 = P2 - P1;
    end
    if M.celltype >= 5
      L3 = P1 - P3;
    end
    if M.celltype >= 10
      L4 = P4 - P1;
    end
  end


  A1 = [];
  function get_As, if ~isempty( A1 ), return; end
    get_Ls;
    
    if size( M.tri,2) > 2
      A1 = cross( L3 , L1 );
    end
    if size( M.tri,2) > 3
      A1 = -A1;
    end
  end
  
  
  vs = [];
  function get_vs, if ~isempty( vs ), return; end
    get_As; get_Ls;
    
    vs = - dot( A1 , L4 ,2)/6;
  end

  
  
  varargout = cell(1,numel(varargin));
  for v = 1:numel( varargin )
    if ~ischar( varargin{v} ), error('quality property must be a string.'); end
    
    get_vs;                    varargout{v} = abs( vs );
    
    
  end
          

end
