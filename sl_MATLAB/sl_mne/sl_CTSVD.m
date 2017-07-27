classdef sl_CTSVD < sl_CImagingInverseAlgorithm
    %SL_CTSVD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        m_matU;
        m_vecS;
        m_matV;        
        
        m_matResult;
    end
    
    methods
        
        function obj = sl_CTSVD(p_ForwardSolution)
            obj.m_ForwardSolution = p_ForwardSolution;
            
            obj.init();
        end
        
        function bool = init(obj)
            if ~isempty(obj.m_ForwardSolution.data)
                [obj.m_matU,t_S,obj.m_matV]=svd(obj.m_ForwardSolution.data); % singular value decomposition
                obj.m_vecS = diag(t_S);
                bool = true;
            else
                bool = false;
            end
        
        end
            
        function obj = calculate(obj, p_Measurement, k)
            
            %y = y(:,10);%erster Sample point
            
            [m,n] = size(p_Measurement.data);
            
            
            ind = 1:k;
            
            obj.m_matResult = zeros(size(obj.m_ForwardSolution.data,2),n); % create empty result for ind=1:k
            
            
            tmp1 = zeros(k,n);
            for i=1:n
                tmp1(:,i) = (obj.m_matU(:,ind)'*p_Measurement.data(:,i))./obj.m_vecS(ind);
            end
            
            tmp2 = obj.m_matV(:,ind)*tmp1;
            
            obj.m_matResult = obj.m_matResult+tmp2;
            

%             % hier die Matlab Code-Fragmente zur Bestimmung der TSVD Lösung:
%             % 
%             % [U,s,V]=svd(A); % singular value decomposition s=diag(s); % diagonal 
%             % vector x=( V(:,1:k) * diag(1./s(1:k)) * U(:,1:k)' ) * y;
%             % 
%             % oder (evtl. numerisch stabiler)
% 
%             [U,s,V]=svd(A); % singular value decomposition 
%             s=diag(s); 
%             x=zeros(size(A,2),1); % create empty result for ind=1:k
%             x=x+((U(:,ind)'*y)./s(ind))*V(:,ind);
%             % end
% 
% 
% 
%             % und für Tikhonov:
% 
%             if ~isempty(R) % regularization matrix R is given
%                 x = (A'*A+alpha*(R'*R))\(A'*y);
%             else % R==[], assuming R==I
%                 if size(A,1)<size(A,2) % underdetermined
%                     x = A'*((A*A'+alpha*eye(size(A,1))\y);
%                 else % overdetermined
%                     x = (A'*A+alpha*eye(size(A,2))\A'*y;
%                 end
%             end
% 
% 
% 
%             % Noch eine Bemerkung zu dem Begriff MNE: dieser ist eigentlich sehr unspezifisch und besagt nur dass irgendeine Norm minimiert wird. Gemeint ist idR die L2-Norm zwischen Messdaten und Vorwärtslösung. Zu dieser Verfahrenklasse gehören auch TSVD / Tikhonov, welche eine unterschiedliche Regularisierung durchführen, um die Stabilität zu verbessern.
%             % 
%             % Notation oben:
%             % A - Kernel / Lead field Matrix
%             % x - Modell- / Quellenparameter
%             % y - Messdaten
%             % alpha,k - Regularisierungsparameter
%             % 
%             % Wenn du Fragen hast, oder es Probleme mit dem Matlab-Code gibt (habe ich aus verschiedenen Routinen zusammenkopiert) melde dich einfach.
%             % 
%             % Viele Grüße,
%             % Roland
        end
        
        
    end
    
end

