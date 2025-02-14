#!/bin/bash


# Основные переменныео
PROCESS_NAME="test"
LOG_FILE="/var/log/monitoring_test.log"
PID_FILE="/var/log/test_old.pid"
MONITOR_URL="https://test.com/monitoring/test/api"

# Работает ли процесс, если нет выход
CURRENT_PID=$(pgrep -x "$PROCESS_NAME")
if [ -z "$CURRENT_PID" ]; then
    exit 0
fi


# проверка перезапуска и первого запуска
if [ -f "$PID_FILE" ]; then
    LAST_PID=$(cat "$PID_FILE")
    if [ "$LAST_PID" != "$CURRENT_PID" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Процесс $PROCESS_NAME был перезапущен. Новый PID: $CURRENT_PID" >> "$LOG_FILE"
    fi
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Первый запуск $PROCESS_NAME. PID: $CURRENT_PID" >> "$LOG_FILE"
fi

# сохранить текущий pid
echo "$CURRENT_PID" > "$PID_FILE"

# Если процесс запущен, то стучаться(по https) на https://test.com/monitoring/test/api 
# Если сервер мониторинга не доступен, писать в лог

POST_DATA="Процесс работает. PID: $CURRENT_PID"
if ! curl -s -o /dev/null -X POST -d "$POST_DATA" "$MONITOR_URL"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Сервер мониторинга $MONITOR_URL недоступен." >> "$LOG_FILE"
fi


