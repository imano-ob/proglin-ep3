% Daniel Barbosa Stein NUSP 5382462
% Renan Teruo Carneiro 6514157

function [ind x] = simplex(A,b,c,m,n,print)
% Does teh simplex ftw

% Se não tivermos soluções satisfatórias, retornamos x vazio
  x = [];
% Muda A e b para que b seja >= 0
   for i = 1:m
     if b(i) < 0
       A(i, 1:n) *= -1;
       b(i) *= -1;
     endif 
   endfor
% fase 1! Teremos, no retorno, um A sem restrições redundantes e um tableau preparado
   tab = fase1(A,b,m,n,print);
% Custo da fase 1 diferente de 0. Não é viável.
   if tab(1,1) != 0
     ind = 1;
     return
   endif
% Fase 2 do simplex!
   [ind x] = fase2(A,b,c,m,n,print,tab);
endfunction



function [A tab m] = fase1(A,b,m,n,print)
  % Vetor de custos diferente para a fase 1. Somatória de y, onde cada y é uma variável artificial.
  tmpc = [ zeros(n,1); ones(m,1)];
  % Precisamos de um A maior para acomodar os y, e manter o problema da forma Ax = b. Assim, teremos [A 0] * [x y]' = Ax + y = b.
  tmpA = [ A zeros(m,m) ];
  % Geramos um tableau inicial
  tab = gentab(A,b,tmpc,m,m+n);
  % Iterações do simplex vão aqui.
  [ind tab] = tabsimplex(m,m+n,print, tab);
  % Custo ótimo diferente de 0. Não é viável o problema.
  if tab(1,1) != 0
    return
  endif
  % Iteramos mais algumas vezes para remover variáveis artificais. Se alguma restar, arrumamos A.
  [tab m] = fixA(tmpA, tab, m, m+n);
endfunction



function [ind x] = fase2(A,b,c,m,n,print,tab)
  % x vazio caso o custo seja -Inf
  x = [];
  % Ja temos um tableau bonito com um ponto inicial. Os custos estão todos errados, porém. Arrumemos isso.
  tab = arrumaTab(tab, c);
  % Simplex, resolva isso pra gente, pro favor.
  [ind tab] = tabsimplex(m,n,print,tab)
  % Agora pegamos o vetor x a partir do tableau, caso o problema tenha solução única.
  if ind == 0
    x = vetorOtimo(tab, m, n);
  endif
endfunction



function [ind tab] = tabsimplex(m,n,print,tab)
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
      ind = -1;
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
  ind = 0;
endfunction
