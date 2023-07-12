# Set up autocomplete in bash into the current shell
source <(kubectl completion bash)

# Add autocomplete permanently to your bash shell.
echo "source <(kubectl completion bash)" >> ~/.bashrc

# kubectl plugins
alias k=kubectl
complete -F __start_kubectl k

# Apply file yaml
alias kaf='kubectl apply -f'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -ti'

# General aliases
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'

# Pod management
alias kgp='kubectl get pods'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'

# Service management.
alias kgs='kubectl get svc'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kdels='kubectl delete svc'

# Namespace management
alias kgns='kubectl get namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kdelns='kubectl delete namespace'

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'

# Secret management
alias kgsec='kubectl get secret'
alias kdsec='kubectl describe secret'
alias kdelsec='kubectl delete secret'

# Deployment management.
alias kgd='kubectl get deployment'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'
kres(){
    kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}

# Rollout management.
alias kru="kubectl rollout undo"
alias krp="kubectl rollout pause"
alias krr="kubectl rollout resume"
alias krh="kubectl rollout history"

# Set the image of a deployment
alias ksi="kubectl set image"

# Statefulset management.
alias kgs="kubectl get statefulsets"
alias kgas="kubectl get statefulsets --all-namespaces"
alias kds="kubectl describe statefulset"
alias kds="kubectl delete statefulset"
alias kss="kubectl scale statefulset"
alias kps="kubectl patch statefulset"

# Node Management
alias kgno='kubectl get nodes'
alias keno='kubectl edit node'
alias kdno='kubectl describe node'
alias kdelno='kubectl delete node'

# Port forwarding
alias kpf="kubectl port-forward"

# Tools for accessing all information
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'
