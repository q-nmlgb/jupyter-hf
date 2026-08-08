import modal

app = modal.App("jupyter123")

# 1. 镜像安装 JupyterLab & jupyter-server-proxy
image = (
    modal.Image.debian_slim()
    .pip_install("jupyterlab")
)

# 2. Web 服务函数
@app.function(
    image=image,
    max_containers=1,       # 限制为 1 个容器实例
    scaledown_window=300,   # 闲置 300 秒自动休眠
    timeout=86400,
)
@modal.web_server(port=8888, startup_timeout=60)
def run_jupyter():
    import subprocess

    subprocess.Popen([
        "jupyter", "lab",
        "--ip=0.0.0.0",
        "--port=8888",
        "--no-browser",
        "--allow-root",
        "--IdentityProvider.token=",
        "--IdentityProvider.password=",
        "--ServerApp.allow_origin=*",
        "--ServerApp.trust_xheaders=True",
        "--ServerApp.disable_check_xsrf=True",
        "--ServerApp.allow_remote_access=True",
        "--LabApp.news_url=None",
        "--LabApp.check_for_updates_class=jupyterlab.NeverCheckForUpdates",
        "--notebook-dir=/home",
    ])
