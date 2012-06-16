% Daniel Barbosa Stein NUSP 5382462
% Renan Teruo Carneiro 6514157

function [ind x] = simplex(A,b,c,m,n,print)
% Does teh simplex ftw

% Se não tivermos soluções satisfatórias, retornamos x vazio
  x = [];
% Muda A e b para que b seja >= 0
   [A b] = tornabpositivo(A,b,m);
% fase 1! Teremos, no retorno, um A sem restrições redundantes e um tableau preparado
   [A tab] = fase1(A,b,m,n,print);
% Custo da fase 1 diferente de 0. Não é viável.
   if tab(1,1) != 0
     ind = 1;
     return
   endif
% Fase 2 do simplex!
   [ind x] = fase2(A,b,c,m,n,print,tab);
endfunction

function [ind A tab] = fase1(A,b,m,n,print)
  tmpc = [ zeros(n,1); ones(m,1)];
  tmpA = [ A zeros(m,m) ];
  tab = gentab(A,b,tmpc,m,m+n);
  [ind tab] = tabsimplex(tmpA,b,tmpc,m,m+n,print,[zeros(n,1); b], tab);
  if tab(1,1) != 0
    return
  endif
  [A tab m] = fixA(tmpA, tab, m, m+n);
endfunction

function [ind x] = fase2(A,b,c,m,n,print,x)
  [ind tab] = tabsimplex(A,b,c,m,n,print,x,tab)
endfunction

function [ind tab] = tabsimplex(A,b,c,m,n,print,x,tab)
  endif
  % Enquanto tiver pelo menos um custo negativo na linha 0 do tableau
  while sum(tab(1,2:n)<0) >= 1
    j = 2;
    %pega a primeira coluna com custo negativo
    while tab( 1, j ) > 0
      j++;
    endwhile
    minrow = 0;
    minval = Inf;
    % Escolhe o pivô; Se não houver nenhum candidato válido, custo é -Inf
    for i = 2:m
      if (tab(i, j) > 0)
        t = tab(i, 1)/tab(i, j)
        if t < minval
          minval = t;
          minrow = i;
        endif
      endif
    endfor 
    if minval == Inf 
      ind = 0;
      return
    endif
    % i = minrow;
    % Divide a linha do pivô pelo pivô, tornando o pivô = 1
    tab(minrow, 1:n) = tab(minrow, 1:n) / tab(minrow,j);
    % pivota
    for i = 1:m
      if i != minrow
        % tab[i] = tab[i]- (tab[i][j]/tab[minrow][j]) * tab[minrow]
        tab(i, 1:n) -= tab(i, j) * tab(minrow, 1:n);
      endif
    endfor
  endwhile
  ind = -1;
endfunction
