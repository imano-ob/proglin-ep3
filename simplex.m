% Daniel Barbosa Stein NUSP 5382462
% Renan Teruo Carneiro 6514157

function [ind x] = simplex(A,b,c,m,n,print)
% Does teh simplex ftw
% Muda A e b para que b seja >= 0
   [A b] = tornabpositivo(A,b,m);
% fase 1!
   [ind x A] = fase1(A,b,m,n,print);
   if ind == 1
     return
   endif
   [ind x] = fase2(A,b,c,m,n,print,x);
endfunction

function [ind x A] = fase1(A,b,m,n,print)
  tmpc = [ zeros(n,1) ones(m,1)];
  tmpA = [ A zeros(m,m) ];
  [ind x tab] = tabsimplex(tmpA,b,tmpc,m,m+n,print,[zeros(1,n) b], []);
  if tab(1,1) > 0
    x = 
    ind = 1;
  endif
  [A tab x m] = fixA(tmpA, tab, x, m, n);
endfunction

function [ind x] = fase2(A,b,c,m,n,print,x)
  [ind cost x tab] = tabsimplex(A,b,c,m,n,print,x,tab)
endfunction

function [ind cost x tab] = tabsimplex(A,b,c,m,n,print,x,tab)
  if tab == []
    tab = gentab(A,b,c,m,n,x);
  endif
  while %algo
    %rodaisimplex
    if % custo vai ser menas infinito
      ind = 0;
      return
    endif
  endwhile
  ind = -1;
endfunction
