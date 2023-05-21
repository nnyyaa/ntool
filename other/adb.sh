#事实上,这个功能的初衷是我自己要用XD
function check_tun(){
    ifconfig -a | grep tun
    EXITSTATUS=$?
    if [ ${EXITSTATUS} = 0 ];then
        echo -e "${RED}检测到VPN连接.停止运行"
        read -p "按回车继续"
        adb_main
    fi
}

function adb_pair(){
    echo -e "${RED}警告!本功能仅支持能够使用无线adb的设备!不支持无线adb的设备将无法使用!"
    echo -e "${GREEN}请进入手机的开发者选项打开无线adb功能"
    read -p "选择与\"配对码\"有关的选项并将码填写至此: " PAIRCODE
    read -p "输入同时出现的端口: " PAIRPORT
    read -p "${YELLOW}确保你未使用VPN!${GREEN}如果有使用,请${YELLOW}现在关闭."
    check_tun
    echo -e "${RESET}"
    adb pair $(ifconfig | grep "inet" | grep -v "127.0.0.1" | grep -v "inet6" | awk '{print $2}' | tr -d "addr:"):${PAIRPORT} ${PAIRCODE}
    EXITSTATUS=$?
    if [ ${EXITSTATUS} != 0 ];then
        echo -e "${RED}配对出错了!如果你还是不知道如何配对,请参考${BLUE}shizuku${RED}的配对方法.${RESET}"
        exit 1
    fi
}

function adb_main(){
    adb_pair
    CHOICE=$(dialog --output-fd 1 --title "ntool:adb_main" --menu "本页面所有功能仅供支持无线adb的设备使用!\n选择一个以继续" 15 70 8 \
    "1" "修复类原生ROM网络连接受限" \
    "2" "进入rec/fastboot" \
    "0" "返回上级菜单")
    case ${CHOICE} in
        1)
            echo -e "${BLUE}使用MIUI genarate 204"
            adb shell settings put global captive_portal_https_url https://connect.rom.miui.com/generate_204
            adb shell settings put global captive_portal_http_url http://connect.rom.miui.com/generate_204
            echo -e "${GREEN}完成!请开关飞行模式或重启手机使其生效${RESET}"
            ;;
        2)
            echo -e "${BLUE}1. system\n2. recovery\n3. fastboot\n4. edl"
            read -l "选择一个以继续: ${RESET}" REBOOTMODE
            case ${REBOOTMODE} in
                1)
                    MODE=
                    ;;
                2)
                    MODE=recovery
                    ;;
                3)
                    MODE=fastboot
                    ;;
                4)
                    MODE=edl
                    ;;
                *)
                    echo -e "${RED}出错了!输入正确的数字啊qwq${RESET}"
                    exec adb_main
                    ;;
            esac
            echo -e "${RED}"
            read -p "你确定要继续吗?你未保存的工作数据将丢失! [CTRL-C:exit ENTER:continue]"
            adb reboot ${MODE}
            ;;
        0)
            other_main_tui
            ;;
    esac
}
