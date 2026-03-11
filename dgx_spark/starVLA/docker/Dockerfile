ARG NGC_TORCH_VER=25.03

FROM nvcr.io/nvidia/pytorch:${NGC_TORCH_VER}-py3

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV WORKSPACE=/workspace

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

# Workspace 생성 + starVLA clone + LIBERO clone
RUN mkdir -p ${WORKSPACE} && cd ${WORKSPACE} && \
    git clone https://github.com/moonjongsul/starVLA.git && \
    git clone https://github.com/moonjongsul/LIBERO.git

# starVLA requirements.txt 설치
RUN cd ${WORKSPACE}/starVLA && pip install -r requirements.txt
# flash-attn 대신 wheel로 설치
RUN pip install --no-cache-dir \
    flash-attn \
    --find-links https://github.com/Dao-AILab/flash-attention/releases \
    --no-build-isolation
RUN cd ${WORKSPACE}/starVLA && pip install -e .
# fast 모델 다운로드
RUN mkdir -p ${WORKSPACE}/starVLA/playground/Pretrained_models && \
    huggingface-cli download physical-intelligence/fast \
    --local-dir ${WORKSPACE}/starVLA/playground/Pretrained_models/fast

# LIBERO requirements.txt 설치
RUN cd ${WORKSPACE}/LIBERO && pip install -r requirements.txt
# robomimic 설치 (egl_probe 제외)
RUN pip install robomimic==0.2.0 --no-deps && \
    pip install $(pip show robomimic | grep Requires | sed 's/Requires: //' | tr ',' '\n' | grep -v egl_probe | tr '\n' ' ')
RUN cd ${WORKSPACE}/LIBERO && pip install -e .

# ---- 쉘 환경 설정 (bashrc 등록)
RUN echo "alias eb='nano ~/.bashrc'" >> ~/.bashrc && \
    echo "alias sb='source ~/.bashrc'" >> ~/.bashrc && \
    echo "alias pv='pip index versions'" >> ~/.bashrc && \
    echo "alias pi='pip install'" >> ~/.bashrc && \
    echo "alias pl='ps -ef | grep python'" >> ~/.bashrc && \
    echo "alias kl='kill -9'" >> ~/.bashrc

# 환경변수 기본값 (compose에서 override 가능)
ENV PYTHONUNBUFFERED=1 \
    TOKENIZERS_PARALLELISM=false \
    HF_HOME=/root/.cache/huggingface \
    CUDA_HOME=/usr/local/cuda

WORKDIR ${WORKSPACE}
CMD ["/bin/bash"]