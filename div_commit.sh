#!/bin/bash

# 한 번에 커밋할 파일 갯수 설정
CHUNK_SIZE=10
# 원격 저장소 이름 (보통 origin)
REMOTE_NAME="origin"
# 푸시할 브랜치 이름 (보통 main 또는 master)
BRANCH_NAME="main"

# 변경된 파일 목록을 배열에 저장 (Untracked 파일 포함 시 find . -maxdepth 1 -type f 사용 고려)
# 아래는 '수정되거나 추가된' (M 또는 A 상태) 파일을 가져옵니다.
FILES=($(git status --porcelain | awk '{print $2}'))
TOTAL_FILES=${#FILES[@]}
COMMITS_NEEDED=$(( (TOTAL_FILES + CHUNK_SIZE - 1) / CHUNK_SIZE ))

echo "총 파일 수: $TOTAL_FILES"
echo "예상 커밋 수: $COMMITS_NEEDED"

for ((i=0; i<TOTAL_FILES; i+=CHUNK_SIZE)); do
    CHUNK=("${FILES[@]:i:CHUNK_SIZE}")
    COMMIT_MSG="Add/Update files $((i + 1)) to $((i + CHUNK_SIZE < TOTAL_FILES ? i + CHUNK_SIZE : TOTAL_FILES))"
    
    echo "--- 커밋 생성 중: $COMMIT_MSG ---"
    
    # 선택된 파일들만 git add
    for FILE in "${CHUNK[@]}"; do
	echo "$FILE"
        git add $FILE
    done
    
    # 커밋
    git commit -m "$COMMIT_MSG"
    
    echo "--- 푸시 중 ---"
    # 원격 저장소로 푸시
    git push $REMOTE_NAME $BRANCH_NAME
    
    echo "--- 완료 ---"
done

echo "모든 파일 푸시 완료."

