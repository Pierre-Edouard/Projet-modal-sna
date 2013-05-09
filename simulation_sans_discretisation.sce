//------------------------------------------------------------------------------
// Simulation trajectoire exacte sans discr�tisation en temps.
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
// Renvoie une matrice � deux lignes repr�sentant les temps d'arriv� et d'envoie
// des paquets
//------------------------------------------------------------------------------
//
// lambda : (reel) Parametre de la loi d'arrivee des paquets
// mu : (reel) Parametre de la loi d'envoi des paquets.
// tmax : (reel) Temps jusqu'auquel on veut pouvoir simuler le syst�me
//
// T : (vecteur ligne) La taille du vecteur est le nombre de sauts n�cessaires pour
//    parvenir au temps tmax. Correspond aux temps successifs d'arriv� des paquets.
// V : (vecteur ligne) La taille du vecteur est le nombre de sauts n�cessaires pour
//    parvenir au temps tmax.  Correspond aux temps sucessifs de d�part des paquets.
//
function [T,V]=simulationExacte(lambda, mu, tmax)
    T = [0]
    t = 0
    n = 1000
    // Calcul des temps d'arriv�e des paquets. On en ajoute tant que l'on n'a
    // pas atteint tmax.
    while t<tmax
        Tinter = grand(1, n, 'exp', 1/lambda)
        T = [T, cumsum(Tinter) + T(length(T))]
        t = T(length(T))
    end
    
    // On limite la taille du tableau � l'indice du premier temps sup�rieur �
    // tmax.
    X = find(T>tmax)
    T = T(:, 1:X(1))
    
    // Calcul des temps d'envoie de paquets. V_{i} est le temps de d�part du
    // paquet i
    E = grand(1, length(T), 'exp', 1/mu)
    V = [T(1)+E(1)]
    for i = 2:length(T)
        V = [V, max(V(i-1), T(i))+E(i)]
    end
endfunction

//------------------------------------------------------------------------------
// Simule une trajectoire de l'�tat du syst�me � l'aide de la fonction auxiliaire
// 'simulationExacte'
//------------------------------------------------------------------------------
//
// lambda : (reel) Parametre de la loi d'arrivee des paquets
// mu : (reel) Parametre de la loi d'envoi des paquets.
// x : (vecteur ligne) Temps pour lesquels on d�sire obtenir l'�tat du syst�me
//
// X: (vecteur ligne) Valeur de l'encombrement aux instants donn�s par x
//
function X=trajectoireExacte1(lambda, mu, x, nbTraj)
    tmax = x($)
    X = []
    for i=1:nbTraj
        [T,V] = simulationExacte(lambda, mu, tmax)
        [indT, occT, infT] = dsearch(x, T)
        [indTE, occTE, infTE] = dsearch(x, V)
        X = [X; indT - indTE]
    end
endfunction


//------------------------------------------------------------------------------
// Simule une trajectoire de l'�tat du syst�me sans fonction auxiliaire par la 
// m�thode de l'�nonc�. Ici, on ne choisit pas les temps pour lesquels on calcule
// X: il s'agit des temps pour lesquels l'encombrement varie.
//------------------------------------------------------------------------------
//
// lambda : (reel) Parametre de la loi d'arrivee des paquets
// mu : (reel) Parametre de la loi d'envoi des paquets.
// tmax : (reel) Temps jusqu'auquel on veut pouvoir simuler le syst�me
//
// T : (vecteur ligne) Temps pour lesquels la valeur de l'encombrement change
// X : (vecteur ligne) Valeurs correspondantes de l'encombrement
//
function [T,X]=trajectoireExacte2(lambda, mu, tmax)
    X = [0]
    T = [0]
    i = 2
    n = 1000
    while T($)<=tmax
        i1 = 1
        T1 = grand(1, n, 'exp', 1/lambda)
        i2 = 1
        T2 = grand(1, n, 'exp', 1/(lambda+mu))
        U = grand(1, n, 'def')
        e = 1*(U<=lambda/(lambda+mu)) + (-1)*(U>lambda/(lambda+mu))
        while (T($)<tmax) & (i1<=n) & (i2<=n)
            if X(i-1)==0 then
                T(i) = T(i-1) + T1(i1)
                X(i) = 1
                i1 = i1 + 1
            else
                T(i) = T(i-1) + T2(i2)
                X(i) = X(i-1) + e(i2)
                i2 = i2 + 1
            end
            i = i+1
        end
    end
endfunction


//------------------------------------------------------------------------------
// Repr�sente une trajectoire de l'encombrement m�moire.
//------------------------------------------------------------------------------
//
// lambda : (reel) Parametre de la loi d'arrivee des paquets
// mu : (reel) Parametre de la loi d'envoi des paquets.
// tmax : (reel) Temps jusqu'auquel on veut pouvoir simuler le syst�me
// nbPoints: (vecteur ligne) Points en lesquels afficher l'�tat du syst�me, si 
//           l'on utilise 'trajectoireExacte1' pour la simulation
//
// traj (string) : (soit 'traj1' soit 'traj2') D�termine quel m�thode on applique pour
//        simuler la trajectoire
//
function evolutionTrajectoire(lambda, mu, tmax, nbPoints, traj)
    if traj=='traj1' then
        x = linspace(0, tmax, nbPoints)
        X = trajectoireExacte1(lambda, mu, x, 1)
    elseif traj=='traj2' then
        [x, X] = trajectoireExacte2(lambda, mu, tmax)
    end
        
    plot2d2(x, X, style=[color('red')])
    legend('Evolution de l''encombrement m�moire en fonction du temps', pos=-5)
    l=get('current_entity')
    l.font_style = 5;
    l.font_size=2
    xlabel('Temps', 'fontsize', 2)
    ylabel('Encombrement', 'fontsize', 2)
endfunction












