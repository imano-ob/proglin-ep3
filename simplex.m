% Daniel Barbosa Stein NUSP 5382462
% Renan Teruo Carneiro 6514157

function [ind x] = simplex(A,b,c,m,n,print)
% Does teh simplex ftw

% Se não tivermos soluções satisfatórias, retornamos x vazio
  x = [];
% Muda A e b para que b seja >= 0
  for i = 1:m
     if b(i) < 0
       A(i, 1:n) = -A(i, 1:n);
       b(i) = -b(i);
     endif 
   endfor
% fase 1! Teremos, no retorno, um A sem restrições redundantes e um tableau preparado
   [tab m A b] = fase1(A,b,m,n,print);
% Custo da fase 1 diferente de 0. Não é viável.
   if tab(1,1) != 0
     ind = 1;
     return
   endif
% Fase 2 do simplex!
   [ind x] = fase2(A,b,c,m,n,print,tab)
endfunction



function [tab m A b ] = fase1(A,b,m,n,print)
  % Geramos um tableau inicial
  tab = genPhase1Tab(A,b, m, n);
  % Iterações do simplex vão aqui.
  [ind tab] = tabsimplex(m,m+n,print, tab);
  % Custo ótimo diferente de 0. Não é viável o problema.
  if tab(1,1) != 0
    return
  endif
  % Iteramos mais algumas vezes para remover variáveis artificais. Se alguma restar, arrumamos A.
  [tab m zerobases] = removeArtificialBases(tab,m,n);
  zerobases = zerobases -1;
  A(zerobases, :) = [];
  b(zerobases) = [];
%  c(zerobases) = [];
endfunction



function [ind x] = fase2(A,b,c,m,n,print,tab)
  % x vazio caso o custo seja -Inf
  x = [];
  % Ja temos um tableau bonito com um ponto inicial. Os custos estão todos errados, porém. Arrumemos isso.
  tab = fixCost(A, c, m, n, tab);
  % Simplex, resolva isso pra gente, pro favor.
  [ind tab] = tabsimplex(m,n,print,tab);
  % Agora pegamos o vetor x a partir do tableau, caso o problema tenha solução única.
  if ind == 0
    aux = getBaseInd(tab, m, n);
    x = zeros(n, 1);
    x(aux) = tab(2:m+1);
  end
endfunction



function [ind tab] = tabsimplex(m,n,print,tab)
  n++;
  m++;
  % Enquanto tiver pelo menos um custo negativo na linha 0 do tableau
  while sum(tab(1,2:n)<0) >= 1
    j = 2;
    %pega a primeira coluna com custo negativo
    while tab( 1, j ) >= 0
      ++j;
    endwhile
    minrow = 0;
    minval = Inf;
    % Escolhe o pivô; Se não houver nenhum candidato válido, custo é -Inf
    for i = 2:m
      if (tab(i, j) > 0)
        t = tab(i, 1)/tab(i, j);
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
    tab(minrow, :) = tab(minrow, :) / tab(minrow,j);
    % pivota
    for i = 1:m
      if i != minrow
        % tab[i] = tab[i]- (tab[i][j]/tab[minrow][j]) * tab[minrow]
        tab(i, :) -= tab(i, j) * tab(minrow, :);
      endif
    endfor
  endwhile
  ind = 0;
endfunction



function tab = genPhase1Tab(A,b,m,n)
  c = [zeros(n,1); ones(m,1)];
  A = [A eye(m)];
  tab = zeros(m+1, m+n+1);
  tab(1,1) = -(c(n+1:m+n)' * b);
  tab(2:m+1, 1) = b;
  tab(2:m+1, 2:m+n+1) = A;
  tab(1, 2:n+m+1) = c' - ones(1,m) * [A];
endfunction 



function tab = fixCost(A, c, m, n, tab)
  ind = getBaseInd(tab, m, n);
  cb = c(ind);
  tab(1,1) = -(cb' * tab(2:m+1, 1));
  B = A(:, ind);
  B * inv(B);
  tab(1, 2:n+1) = c'- cb' * inv(B) * A;
endfunction


function ind = getBaseInd(tab, m, n)
  m = m + 1;
  n = n + 1;
  aux = eye(m-1);
  ind = zeros(1, m-1);
  for j = 2:n
    for i = 2:m
      if tab(2:m, j) == aux(:, i-1) & tab(1, j) < 0.0001
        ind(i-1) = j-1;
        break
      endif
    endfor 
  endfor
endfunction
  
function [tab m zerobases] = removeArtificialBases(tab_o,m,n)
  % tab = O tableau atual
  % ind_o = indices atuais
  % n = numero de bases originais
  mfim = m;
  zerobases = [];
  ind_o = getBaseInd(tab_o, m, m+n);
  for i = 2:m+1
	  if (ind_o(i-1) > n)	  
	  % Esta base e artificial, precisamos remove-la
	  % Localiza com quem devo trocar o meu índice
	    artifBase = i;
	    zeroCount = 0;
	    for k = 2:n+1
	      if tab_o(artifBase,k) == 0
		      zeroCount = zeroCount + 1; % Número de Zeros detectados + 1
		    else
		     % é não zero, devemos escolher esta para com a base artificial, as devemos ver se ela não está na lista de índices!
		      if verificaSeEstaNaLista(ind_o,m,k)
		        %está na lista, não pode ser usada.
		     else 
		      %não está na lista, entao escolhemos ela (colocar k em j)
			    % alterar na lista de indices (indice da artif agora é da original)
			    j = k;
			    ind_o(i-1) = k;
			    k = n+1; % terminar o loop aqui
		    endif
		  endif
	  endfor
	  if zeroCount == n
	    zerobases = [zerobases artifBase];
	    mfim --;
	    break;
	    %existem zeros em todas a artifBase-esima linha, entao esta linha é redundante!
	  endif
	  
	  % executa a troca
	  minrow = artifBase; % pivô (a base artificial que via sair)
	  j = ind_o(artifBase -1) + 1;
	  % Divide a linha do pivô pelo pivô, tornando o pivô = 1
      tab_o(minrow, 1:n) = tab_o(minrow, 1:n) / tab_o(minrow,j);
      % pivota
      for i = 1:m
        if i != minrow
          % tab[i] = tab[i]- (tab[i][j]/tab[minrow][j]) * tab[minrow]
          tab_o(i, 1:n) -= tab_o(i, j) * tab_o(minrow, 1:n);
        endif
      endfor	  
	  endif
  endfor
  m = mfim;
  tab_o(zerobases, :) = [];
  tab = tab_o(:, 1:n+1);
endfunction
  
function res = verificaSeEstaNaLista(ind,m,id)
  res = false;
  for i = 1:m
    if ind(i) == id
	  res = true;
	  return;
	endif
  endfor
endfunction
