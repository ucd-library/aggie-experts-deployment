aggie-experts.service is a sample script that can be used to register systemd cmds

## Systemd Files


```
sudo systemctl enable /opt/aggie-experts-deployment/compose/prod/systemd/aggie-experts.service
```

Then

```bash
> sudo service aggie-experts [start|stop] 
```