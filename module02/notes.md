## kestra

### Use an SSH Tunnel to port forward
This method forwards port 8181 securely from your VM to your local machine.

Steps:
On Your Local Machine, Run:
```zsh
ssh -L 8181:localhost:8181 <your-gcp-user>@<your-gcp-vm-ip>
```
example:
```zsh
ssh -L 8181:localhost:8181 ubuntu@34.125.45.67
```
this will forward port 8181 from the GCP VM to your local machine,
so you could run:
```zsh
http://localhost:8181
```
