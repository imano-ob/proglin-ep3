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
   [ind tab m A b base] = fase1(A,b,m,n,print);
% Custo da fase 1 diferente de 0. Não é viável.
   if ind != 0
     printf("Problema inviavel!\n");
     return
   endif
% Fase 2 do simplex!
   [ind x] = fase2(A,b,c,m,n,print,tab, base);
   if(print)
     if(ind == -1)
       printf("Problema ilimitado com custo menos infinito!\n");
     else
       printf("\nx = \n");
	   for i = 1:n
	     printf("      %.3f\n", x(i));
	   endfor
     endif
       printf("\n")
	endif
endfunction



function [ind tab m A b base] = fase1(A,b,m,n,print)
  if print == true
    printf("\nSimplex: Fase 1\n\n"); 
  endif
  % Geramos um tableau inicial
  [tab base] = genFase1Tab(A,b, m, n);
  % Iterações do simplex vão aqui.
  [ind tab base] = tabsimplex(m,m+n,print, tab, base);
  % Custo ótimo diferente de 0. Não é viável o problema.
  if abs(tab(1,1)) > 0.0001
    ind = 1; 
    return
  endif
  % Iteramos mais algumas vezes para remover variáveis artificais. Se alguma restar, arrumamos A.
  [tab m zerobases base] = removeArtificialBases(tab,m,n,base);
  zerobases = zerobases -1;
  A(zerobases, :) = [];
  b(zerobases) = [];
  tab(zerobases+1, :) = [];
  base(zerobases) = [];
  ind = 0;
endfunction



function [ind x] = fase2(A,b,c,m,n,print,tab,base)
  if print == true
    printf("\nSimplex: Fase 2\n\n"); 
  endif 
  % x vazio caso o custo seja -Inf
  x = [];
  % Ja temos um tableau bonito com um ponto inicial. Os custos estão todos errados, porém. Arrumemos isso.
  tab = fixCost(A, c, m, n, tab,base);
  % Simplex, resolva isso pra gente, pro favor.
  [ind tab base] = tabsimplex(m,n,print,tab,base);
  % Agora pegamos o vetor x a partir do tableau, caso o problema tenha solução única.
  if ind == 0
    %aux = getBaseInd(tab, m, n);
    x = zeros(n, 1);
    x(base) = tab(2:m+1);
  end
endfunction



function [ind tab base] = tabsimplex(m,n,print,tab,base)
  n++;
  m++;
  iteracao=0;
  % Enquanto tiver pelo menos um custo negativo na linha 0 do tableau
  while sum(tab(1,2:n)<0) >= 1
	%conta a iteração
    iteracao++;
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

	%Impressao
	if print == true
	  printf("\nIteracao %d\n",iteracao);
	  imprimeIteracao(m,n,tab,base,minrow,j);
    endif
	
    % Divide a linha do pivô pelo pivô, tornando o pivô = 1
    tab(minrow, :) = tab(minrow, :) / tab(minrow,j);
    [tab base] = pivota(tab,m,minrow,j,base);
	

  endwhile
  if(print)
    printf("\nFinal\n");
    imprimeIteracao(m,n,tab,base,0,0);
    printf("\nCusto : %.3f\n", -tab(1,1));
  endif
  ind = 0;
endfunction



function [tab base] = genFase1Tab(A,b,m,n)
  c = [zeros(n,1); ones(m,1)];
  A = [A eye(m)];
  tab = zeros(m+1, m+n+1);
  tab(1,1) = -(c(n+1:m+n)' * b);
  tab(2:m+1, 1) = b;
  tab(2:m+1, 2:m+n+1) = A;
  tab(1, 2:n+m+1) = c' - ones(1,m) * [A];
  base = n+1:n+m;
endfunction 



function tab = fixCost(A, c, m, n, tab, base)
  cb = c(base);
  tab(1,1) = -(cb' * tab(2:m+1, 1));
  tab(1, 2:n+1) = c'- cb' * tab(2:m+1, 2:n+1);
endfunction


  
function [tab m zerobases base] = removeArtificialBases(tab,m,n,base)
  % tab = O tableau atual
  % n = numero de bases originais
  mfim = m;
  zerobases = [];
  for i = 2:m+1
	  if (base(i-1) > n)	  
	  % Esta base e artificial, precisamos remove-la
	  % Localiza com quem devo trocar o meu índice
	    artifBase = i;
	    zeroCount = 0;
	    for k = 2:n+1
	      if tab(artifBase,k) == 0
		      zeroCount = zeroCount + 1; % Número de Zeros detectados + 1
		    else
		     % é não zero, devemos escolher esta para com a base artificial, as devemos ver se ela não está na lista de índices!
		      if verificaSeEstaNaLista(base,m,k)
		        %está na lista, não pode ser usada.
		     else 
		      %não está na lista, entao escolhemos ela (colocar k em j)
			    % alterar na lista de indices (indice da artif agora é da original)
			    j = k;
			    base(i-1) = k;
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
	  j = base(artifBase-1) + 1;
	  % Divide a linha do pivô pelo pivô, tornando o pivô = 1
      tab(minrow, 1:n) = tab(minrow, 1:n) / tab(minrow,j);
      [tab base] = pivota(tab,m,minrow,j,base);
	  endif
  endfor
  m = mfim;
  tab = tab(:, 1:n+1);
endfunction


  
function res = verificaSeEstaNaLista(base,m,id)
  res = false;
  for i = 1:m
    if base(i) == id
	  res = true;
	  return;
	endif
  endfor
endfunction




function [tab base] = pivota (tab,m,minrow,j,base)
  for i = 1:m
    if i != minrow
      % tab[i] = tab[i]- (tab[i][j]/tab[minrow][j]) * tab[minrow]
      tab(i, :) -= tab(i, j) * tab(minrow, :);
    endif
  endfor
  base(minrow-1) = j-1;
endfunction

function imprimeIteracao(m,n,tab,base,pivol,pivoc)
	  printf("             |");
	  for p = 1:n-1
	    printf(" x%d       |",p);
	  endfor
	  printf("\n    ");
	  for p = 1:n
	   printf("%8.3f | ",tab(1,p));
	  endfor
	  printf("\n---");
	  for p = 1:n
	   printf("-----------");
	  endfor
	  printf("\n");
	  for p = 1:m-1
	    printf(" x%d ",base(p));
		for q = 1:n
		  if pivol == p+1 && pivoc == q	
            printf("%8.3f*| ",tab(p+1,q));		  
		  else
	        printf("%8.3f | ",tab(p+1,q));
	      endif
	    endfor
		printf("\n");
	  endfor
endfunction
