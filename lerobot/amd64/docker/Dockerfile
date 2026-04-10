ARG NGC_TORCH_VER=25.12

FROM nvcr.io/nvidia/pytorch:${NGC_TORCH_VER}-py3

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV WORKSPACE=/workspace

# 빌드 캐시 무효화 -> 이 밑으로 모든 코드 새로 실행
ARG CACHE_BUST=$(date +%s)

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev python3-venv \
    git git-lfs curl net-tools ffmpeg gedit nano tmux ca-certificates \
    locales software-properties-common htop \
    python-is-python3 \
    build-essential ninja-build cmake pkg-config \
    libstdc++-14-dev x11-apps \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/python3 /usr/bin/python
RUN python -m pip install --upgrade pip wheel

# Workspace 생성 + lerobot clone
RUN mkdir -p ${WORKSPACE} && \
    git clone https://github.com/moonjongsul/lerobot.git ${WORKSPACE}/lerobot

# lerobot requirements.txt 설치
RUN cd ${WORKSPACE}/lerobot && \
    pip install -e . && \
    pip install -e ".[smolvla]" && \
    pip install -e ".[pi]" && \
    pip install -e ".[xvla]"

RUN pip uninstall cmake -y
RUN cd ${WORKSPACE}/lerobot && pip install -e ".[libero]"

RUN pip install --no-cache-dir ffmpeg torchcodec pyzmq msgpack msgpack-numpy

# flash-attn 대신 wheel로 설치
RUN pip install --no-cache-dir \
    flash-attn \
    --find-links https://github.com/Dao-AILab/flash-attention/releases \
    --no-build-isolation

# robomimic 설치 (egl_probe 제외)
RUN pip install robomimic==0.2.0 --no-deps && \
    pip install $(pip show robomimic | grep Requires | sed 's/Requires: //' | tr ',' '\n' | grep -v egl_probe |tr '\n' ' ') 

# ---- 쉘 환경 설정 (bashrc 등록)
RUN echo "" >> ~/.bashrc && \
    echo "export PS1='\[\e[1;31m\][LeRobot]\[\e[0m\] \[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '" >> ~/.bashrc && \
    echo "export LS_COLORS='di=1;97;42:ow=1;97;42:tw=1;97;42'" >> ~/.bashrc && \
    echo "" >> ~/.bashrc && \
    echo "alias eb='nano ~/.bashrc'" >> ~/.bashrc && \
    echo "alias sb='source ~/.bashrc'" >> ~/.bashrc && \
    echo "alias cw='cd /workspace'" >> ~/.bashrc && \
    echo "" >> ~/.bashrc && \
    echo "alias pv='pip index versions'" >> ~/.bashrc && \
    echo "alias pi='pip install'" >> ~/.bashrc && \
    echo "" >> ~/.bashrc && \
    echo "alias pl='ps -ef | grep python'" >> ~/.bashrc && \
    echo "alias kl='kill -9'" >> ~/.bashrc && \
    echo "" >> ~/.bashrc

RUN rm -rf ~/.cursor-server

# 환경변수 기본값 (compose에서 override 가능)
ENV PYTHONUNBUFFERED=1 \
    TOKENIZERS_PARALLELISM=false \
    HF_HOME=/root/.cache/huggingface \
    CUDA_HOME=/usr/local/cuda

WORKDIR /workspace
CMD ["/bin/bash"]