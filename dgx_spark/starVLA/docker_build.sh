#!/bin/bash

# 1. 이미지 이름 및 태그 설정
NGC_TORCH_VER="25.03"
BUILD_IMAGE_NAME="moonjongsul/starvla-dgx-spark"
TAG="nvcr.io-pytorch-${NGC_TORCH_VER}-py3"
DOCKERFILE="docker/Dockerfile"

echo "=========================================="
echo "🚀 Docker Build 시작: ${BUILD_IMAGE_NAME}:${TAG}"
echo "파일 경로: ${DOCKERFILE}"
echo "=========================================="

# 2. 빌드 시간 측정 및 실행
# BuildKit 활성화 (병렬 빌드 및 성능 향상)
# --no-cache 옵션이 필요하면 아래 명령어 뒤에 추가하세요.
START_TIME=$(date +%s)

DOCKER_BUILDKIT=1 docker build \
  -f "${DOCKERFILE}" \
  -t "${BUILD_IMAGE_NAME}:${TAG}" \
  --build-arg NGC_TORCH_VER=${NGC_TORCH_VER} \
  .

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# 3. 결과 출력
if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "✅ 빌드 성공!"
    echo "소요 시간: $(($DURATION / 60))분 $(($DURATION % 60))초"
    echo "이미지 이름: ${BUILD_IMAGE_NAME}:${TAG}"
    echo "=========================================="
else
    echo "=========================================="
    echo "❌ 빌드 실패! 로그를 확인해 주세요."
    echo "=========================================="
    exit 1
fi
