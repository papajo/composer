ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.12.0
docker tag hyperledger/composer-playground:0.12.0 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �ϞY �=�r�r���d��&)W*�}�r&;㝑DR�dy�����[�u�=����$Z��Ų�ҩ|©��7�y�w�� ���%_ƶfwG�`K`��t7`ұ�FvDÝ.vP�k�~�ƞ�G���À@ ����xR��S�˒�D��rR��	)�Dq1���Z�� <qmxf8��nz�+�3d;���s�9�9�>34�s �N���3�f�а�}b�Z���F6IY��E���&�c��c*�P��v�$ �|MX���Yg�����!Rf���[�UN2��|as�< �2�D�נ�;�:x7Y>� �Ѕe6â�#�B��w�5Y66M*nA��JU��ȥK���j.{]5R	���Eah��!fZв����E�0��`6m����4��Ԟ���n��-�붡]�|9�mt)mZek�l �*�31*\G�%Ung�u�m�?�f��6Ï�p����MO'�h@ӹ���Aأ��k�#��c<�GCZ�mRћvW[���Qt;]��'E�?���Vh�ZQ�Î]S��tYZg�n����u����p���\�Kگ�(&t��/�d"C��Q~�ͱF��h|m��C��_�fJ]�����=��Έ2ߖb��u�ne��ց�����″���v�M1:j@�&t�"ۂ�pZ���N\�sO���Ftt��?Q�؃�A^2�̋�(��_2I�DQ�?�<�$3���f���H�{�?�F��}y��W揿(It�Ÿ"ʒ� 㟔��2�_<�>V7�X:-����!�?{4�����I��2�V�N����L��a��U����t�)vbbH"�,_�������O����r��X���3��6l�詃��������$(,�K(����bB�'����+�p�{Uت�6	)���_:���.�A��9�ŀ����Ӏ�����Kw�H�鸠��t9����t�h��!Vd#��p��� �m������տCV��I˫ӕkl�����Di}.X���s[؞�h�5|�LCC��x��jZ("Pt�,C��R�c<��nb���`�U�;��h�:T�A7w�E����6�.C	��wF�P�S�@[kg�ozfD"�݋Q_�c������d �W� ���x4n"��H����Q9�w��������Q��4��)���5�?�4����}C��?�<��_"��D\!�_Dq��[���S@�<��,���tA�0M -ب��)D��,˰���BVr\�}��]rܞ����Tt�����F�{"� �� <>��$-�
���&�(mH�^����������&'��5�\�dǹKs�Wh#��o��� FD���b>�@<�k�-��z��{�Ga}�7:��q��nܯw���xL`�@��ǴѾ͏��P�v�)1�Y�:Ց����TE�S�-��:d�ti�$��*.}:\�"}���\��+{��*Q�uL>���(�۫�7�=A�HsA�eh-�Yd~<�t6^0�? �وz�B��<eƯr���[@���d����Q�,�1�p�z��*3�� �mۯ_��8��~׼�Z��F�й��ȁ�c-g�/f��T�l����JR\������ϗ3�4����"}�C���,*�D�_�������hƏ����GC"=s:ԣᘍM�����~���6�@��~��粅��'���U��T3��^m��7�����1��*������1��s*�#$�ͫ�J!sr��T����Q���p�g9�}E�t��P~��?��k`��F�J�!�A�i�t)����#",]�\��ZS+��Z���ݯ͗zm��^8���^i�D�Q��@�Bm<��;!������#~޽�f2��xf#���$,��+�:(�P��ԑ̓�~�^����.�:ݡA�%#�7�c����b��Z~R��/g���5�rp�p%���g6�s�'��b�����ˆ��?h�� ����0��K����o���O���Z�0,2 �	"����9��p(`0�/�νa��O�K��q��Ϥ($������ǟ�p�7������� 
�r����$�0�"Y ��' �D�����2�o!0��7GW��"kp�q�ml�]۰���h�-݉rtAg���D?y����<���c�����{S��w\�4}����AxDQ�8�
"0YBϺ��B�rQ!�^Q�X�&�yr��� ?+��#�[S��cO!�N��~cĒ�4�#0� ��ݝz�L���L��H5�3���D�ZFP_$����')���?)Ƨ��x<����_����46}Y������wvQn��Ck��zZM�3���%NrD�
Q�
�����;���ލ���^���I�[��OR�M�O?|����K�,/�����@�e)v�f��P�?L�uLx'6#�v�[
�nk��y)tc�o"1�����󟋁��������|"�Y��(w� �M �u'`�9 �ìc�~p�6D��rZw�Ǡ���JTfI �W�Q�@д9�� 5��{��̓�n�k�'�7u�f������\��l��� na��o	n�n
	�옾�c��̿���x�FpkČk5���y]���2f݆1Qa��ɦN���rk��\{m�͗�̻ e�r>.<7��Y2��.u��C&Ld��;*�Nl�W3������<�z�z�O�q��1_�����������M<� _s�WP����+�"-�E �_s'܇o���w��������S�Ϗ?�x]�dYJ�54Q�l����J%��$KI�d�	9UO�e�)%���5E��)��|���kn������ߪݮi���"+��7�_��m��w�8.�-ۮ�uV�i����6*�Z��W�D���o���y�w�;g�_V�X����4��Dp���6\��+���-A���`��h��NP0��1�;�?���pw�g�x���K�L�d�������_|���wLކ��_�:�2�\���e���5�.5���+��գ�$�+6������<yz�>��R~��w�&ݍ+����'(�(CXP2QoZr-.�5�R����5-%Kq�Ě-.ג0U���,+I���]�"n�Agڜ�tn�P�\�V�2j-�J�[�B!�y�ɨZ���
i�Y��%o�:(����f�M8�6˽L󨰍��B���������7Uq?�n3��܅ZI7K�T-�.��f�����y�T���i��yf�7�[Z'�I�ő�v�YS�����L��/r���V��6�W�Ӻ$�oeU��k9��zo�tfb��ZZ�X�z�ӂT���ZA:�e��L���O��b��e�Gكry3�{s���I���e�����w����Q�G��a1]�[~^,�����W����S��tZ��5�i�a���a����CE%}a���6�yn�tJg�Z���d����ܬ���mf2��^nK
jz�[�>O����y�V<�;g��[�h��TqY���ڛ����><H�����V��P��RL'����Z��,8E}��8�s��fo��VK�U���V��r�X�L�x��U����*Ŵ�X˩��Z�8�Uz�Wn3�j!ݱ���Lҩ��]�i��;�b��k�|�hHo�-��^Q�a��fT��s��B9#;���{+�k~�׎��/R�a*ֲ�_&�U����A�,�ǚ�fU�N�N�M_�y���\�WL%��{��Aqk
F?#��gzi��n�����J�f��h,�y[��j?����l���/�~n`��O��#�3C�oc�^�w��_)|��_��W�|�/aA���?���q� ���"`,Nګ�� �sG��[�X��"s�z���z��P�rS
����66b)�]O|��BU|�J���yf�H��l�-�k��+���,��K�nq�}����ˋ��1��:j~����~���������-i�hfZ��>�^mWB��Xv���d�j�t����o�p�ڰ����e�����_Y�����6�{����%<�e��Ҍ�_Y�,�����N!3>��۽\�h+��Ȩ�p+$���l���`�g���}X˿)�6��#�7�.��Ŀ��n�8_l��U��z�J��������N�µ܎���������լ`Vmnl�O�Ӓ}�^���'���b�X�0��>�ů��`���,M��*2�������dp�o���B�H���(PMTh�*����\̽��Ȏ�m���m�^��o	A�<j�����k7D@5�`S�A���e\�it����� k	XXg'dR�1y���<,qJ/`��#��~�f��,�@�Zc�U���yS�|��46�U� }�@{ԑ�{,����]0�H�0QF?F����Y�@w^������̶GQ�$���M�Q���i�tz�c���߷h�-ͣu[즣�&Yd���5D�4��p�/\���L�鬠�=;��OԞ��*
@�� ϡ��=z�-v�)5D���o�>��k6=1- m�)CZH�rm9�v����>��T$���0 S����t�� xQA=�,/VA�Ŭ�~a��(��-'��zt�N���|�x��\4W�,t��A�腶ab�؆���		N��)����ß{収1Ix}�Ǯ��2:l�`%�|M�k�w������4=����;L��4=@5�1���+`#�K���裩�����Ƥ����b�OJ����Mq�+%)�2�M��넬"�����l��"�g�Huh�)�x<�2����/$�ý���I"R��`������0Eءi�,s�������W��ĸM�m�'j������x2س܈8T�#�ɯ?�K*�S��̈́�����? N�+b7_[::/���j@.hfh�}�&��4קOM��p�W�&X�ĲC�Ȏ$�ΐv�T����T4�s�_1l�`��m����dM��f�FMJ�o��u4��M<:!Z��5ʷg����6M��H��H�S��q��u��>ߺi��%,��n{�2���|,�a��7͜�v��c���6��tnP��3����:���x,��$b����%�u,-w�4M�nz���f��n�Ž~�v�b��v�$N�y:O%'vW�G�N�d�.�4-�4�� v �!1�0,����b�!v�|�q��U��.�V׭�����s����X�k6ѷ��vա���'0�ɕm\��������������<z�����g�?��.��w&E���~������?�����ֳ	�.�|�#�Ǒ�kG�����7�~��o���'��|�IGbE�1��(Q:��$!�-%��U���N�)�'(��)8AP9'���E�BC�ʯ����o]�ďc���?�ӹ�������~C���~����[+����C�{�6�_�~��������b����/����.�-�woB�C Z��b��C��L+ߋ�*Ǧ���U�8�X,ǜ���E��/�s�.�
�-��W!tUSd�N�X܍���";rXsQj�ٝ�Q�6�-B<o���"%�7e���yV��!bZ�'�L�A�5$F�JbI�xgho��Fm>n��@��d�4o�=�[fz�An�&r3�Է��p��Y{��yvP%5�j�*�7Œe��0����y�L��x��j�_$p��r�~�8���;P�=4�|�2-�16N��	n��j2�|�X+���-��L&s�2~a��T�B�����I��@7KX�)�Q��׾��L"�2���L#��I�cq�,9�+�gKf!gE���nJ6����wӄ�O%�B� �e�F$=+
��"��;����Q�Jv�%F�&�sT���lC滢���1�Zk�
=9�Ʉ�����4;�&�T]oW(Z����Ĥ�1f6n�R~n�'��X�x��cU���������_�Mw�^"w�^"wE^"w^"w�]"w�]"wE]"w]"w�\"w�\"wE\"� �W0��F9��7�O���õ�R��9��?�Kx)Ξ/q:�kbz)1\l��^�Ί�bMI͗�=wQ=x(��V=�=�S=1+m7� ��ϛX+};��x����,�t��R��42g��q�EL-ڬI���B�%�Q��&�JK!B�g����@�ɊL6K����	N���H�PE�z��x��y�O�9b:�	&Nb2��ٲ�'�L�e�|i���"�V�W��.U?Y&=#�y���8����RV�`+��6jݸ��"f&�S���ԳQf��t�P�T���ѕf%?i�pr���$�=��2���_��N��^}:
�i������no�֟_ [��y	����J�7�>C�K8��`�oo#]k/B���>�z�����P7�~�Aݚ.{����q�BGv_�}-��߁ˊ����[�(��B��M$�+��o>��|���<���=x��׊���e�������%Cclm�㣥:�t�[:_�^��OrL���	b���V�,oQ���Bnc5����$r�9(�Gt-��.�ܔ�u��x8�o�BA��R����]e!�+�!���ňf��Ev�'��)��3�ܸ�&ϋH�.��٩�� Z���6�
M��צ�Ġ���q�2�M�1b�ڲ>Hf��0�TGx�B��w�L�x���'�t{9-�������� +1@��Q1iA�E�M�r�_4�A�S餎��hԔS�[�\#Y�j���/�SdMQvsi�cyFc�����.�*�A�$�%���mAt1���A�b��銭�>ƌ"���;T{��7g�lM8ϐh[�2:Y�^�*{��o\�4	`(�|C��Ƞ�P�i6�ǲy�;핖[����EdO�g7�䒩z27��<���\ŒuN�#"�X���E��/r��~&8�8��U=��#��w��h�3�{����j�����
G�[�e&�<WLC�%�+�l�h�i��6��pXVsY��_ӊ��Z[&�����j6�Ҡ����EQ(0Ø�8��C����;T�ʈ��ʼc('D��Nf9gEK1��`.R�n�@
�dz>���q�ֻ8��tb��l�B�v������v����cDyzڮ�
j�YU3�Z_�(c>S��2��@�h�|z^*I6�t9���ҩN?��>�t�Åe��x�g0#�D��2���粉��Z��I@�,V�D����E�"g�JO��[V�����HFV�q�<�ُ:r�#1eAe����S&���R���v�S&%`�{
	�y�W(��0R�Tۧ��A����S�6��>���|�`:5"6k�B������u&^n�P�5�x��+�Q������t�!�eo4�m
�i�
%Z�6���1[�.-Y�K��*v334]���Ub��&H_&Ŵ�!y}����V��x��P��|�SJ��4%�^���l��:A���|l�0Y��ʬU�7��<hY"K���k�(G���l���<�����ɷK#+���C߶m�������A��/D�v���DV&��6�/ \[���Ds�������ip����!-�j��Л��H�Y!?��f�W֖j��[GȻϞ=�?|�,���6�6�#9��B��@�F�<;|�|��0���)���x���7�k�R���1�nZ6@�ZF��z`�#������Y8N6e�@~�N�������g�w��ae��j���C�C���=z]���Y9B^s�;���[|�x"s~3�/L�|���Ȗ����o?����6��'�~8�u�z�NG�~'אn��;�0ZjX�n�p����ۏ���d#<�'�@5�SّwR{W���}��rGd������>WƦ����W����]= ��=	��T���!D����y�tu��|f]/���u��kZ�[u��~���9�щ����.�vLM��������"�	:Y�O�R	� �\ �O�A����]�( �� ��f��D���67 D� FW��AE_�oL���v����<�cxj X�x�,pX0�Fo4Օ�P�u v��i����3_���� ���|�V�ت���$��sH�q��,�Qإ�`wA���9��
Zt�78�@} k�u��.����Ù6��~�5�>�\�6��Dj���Y@����_��)X��'�M<l+MN���l�ܡ����5��+s�:	�]BG~�WĀ�Mt`���X�N� ��&��G/���VB ؆��6lkcY?	�Fv�"/�|	Y-j%�ȗ[/$�̀\3�cus�7�7�zP���f�{�	�v�!a?
�Z[�o�æB���"������0�����6�n��CW��� :]l*DO��a�7��Lw�]�[޼���Kh���\��A��Q`[���S$%�I��4���|nu�Z]����E��͖]����А�b�	�l} �u�dMT"[W���6���r_����}���� @���Ke��D{Ꙭ��e��~�%AL�����m�idq����+Nx�l��u�b��c��� �<�б�~Z�� tFj�P9�ea=����0a��R������eQ
�9� \�U導5�"�âS6���sm0�j��v�N�P ~6�{(��[�BƂ�1-{���nͲӞdg������@.��~d9x��^�h�nKYuqձ'+�6a��6��E6ػ���Ŗ���/�a�{l|��۴�#ƽV5���-B$�M�6��[�d��N��|��]M��SwFN��Zf'�>Pv�ùt�[�H�P�fu]���ry�?x�P8�Q�#s�6����8}��x:'q,N�$E�r�ky]���N��$p���n(M�D �o1�n�+��0TMk4�rc�R~��qC��~T�P��Q�b��];�����p��u�����1q�m��������<��O+��$���dG�GV�@k'7��rv<���I�-	��sBc<EU����%��|�ʗ�o9ƮbGo���*��%��_m[��<�>��4t�7��� ���!�-*'T����Cӝv[��J���2ъ���	��iu�L�1U&h���;�����G Ċg>s���fi/���d�?��~l?y�
���x;ğ0�ξ�x�*�ܢ)��jad�*��*���,�4M��(�cjDn) ���g2Wɨ�˴��~�r ���c+�X����6�j`���Ͻyn���MG�.���̹(���팻6;���x��>x)��K_��:����=��SY��g�*jkڽ<�P���q%�\~�A�
�47��,�E^J繧�������;������J0Y�\�����r�XW[]c����*�Ʒ�dg
8�AGc���jL�hW3{�$���Z�Z�E�N�Fg縃��ަSo�ֲ=���(
�A�`�[ݜ!���G$�	����i~;��ȗx@�)!�:+�|i����D�r�<���0ǳ��z֪x��B^�IO�Cm~��(�j���	:�]��$PX4~f��H���]2��ti�o\>qjM��R"�K
��/��S��S��΂�v�]��Lr;��ԩ��H�m���e�<��˖%F❟#1,S�&@4T��""_I�9����7A^0U*#_(���[|M
�<vg^�|ڑuC�����E!�`ܱ˸�'��u��;��@���Yt7��f��u�e�Е�n�_��u��l�mp�i���%	 �<�ح��|W˛��zw,9 ��G{V)e�66��B�@�Eg��7�>��������M�M⿬���N��#�q��tG7]���O�z��酯������G��뿏�J����m������>���S7��m��>�����^ҫ �	۔�T�<��}�}����/�=_ٴ/���_�""�����}/����������z��o�~��J�Ԏ�_�o/i_����e{�Q�։�ܖ$�)�N�j��܎Gcx[�cX�iG�h�%cjST�$�����^���Ʒ��C�������&��Z��64��H����r\�:hZl���E��H�a��yu��^�O5����)�-c���ƌV"*�5�&�+-
��XE;����y٘����I9�8�t��IOO'�,���6L�ƨ�]����v~��U������K/_�;����!�N�X�ۜ������>ҫ �	l��� ����%�/����� �����������>�=� Ӿ�)�J���?��{���bo������W@�Û� t8%�:�����w�O���>��}�WK�C?��P��K��޵5'�v�{~�{o���p�V}�TDP<p� "�@QQ~��I�{�u&�t���ue9��]����멊��i��&�;�'!���Q�pT'�����) ����0�Q	���m���s�?$����� ���?�� �����$	����k��u������O��<�6�Љ�|����gY��ghH����s[��~f���ft�w�~�V?���~E��dVS����|Y��VI�SI�W����z�"mf�ݢ�k��
g7�r�(�Bs�l������w���Xآl�̓M�S������������'�#{�m���q�wȃztĝ��`^�))͞,m�^z��j��v���}ʗ���v�i꫱q���f�F�s�}#�h9��ʴ�{�X�ړu�2���a(���x������e��b���G����L$���k��iA,�z ����H�?��kZ�)QU���A�	�W���'����z�����W�y��]���s�?$�����W�g��� R�������@�P���}xu�߹������9�Ω��9K꺵N��:�q�������s]���/���b�_�c������qu�g-XG��P^�.8X��F�1�gZ����.�y�Pl8�Q�=M�ₐKA᷻Θ�����2<���!k���?���_��H4�⩮W�wdC���_J�Uh���6>���k߾�¡�-D�N�NIb:%��i�]��6R�h;]��)��LJ2�mo㶘�}�L���"4iI��+&{¨��&�i�|�!��9����7 ����� �W����}����s�?��������J������s���8K��	h��A"<�>�C��|�I*q*dC�� �p8#�ǁ�?�����������y��H��j�,��9ڗ�9ۈB�:�e˘��-���x~foO�pq
��q�x���9;r�Ʀ���_M��n��fK�A��8��DQ�� \�td͘�ۇ�vx��Y���
����Yj������(�����H�?��������q-�~3>!P����ï�����:G]m��㘋m��笘	�����p���e��Q�_�?�G�}u$ǃf���%g�Bfv�>U6ؼ��P����b|�yJwd7.�B�̏�o
�����RE\��N�1P��h��I�k����#������(���W}��/����/����_��h�:����;�GQ����k��+��/f���b�ЖE?:n&\�j���w���e-���8{��om�9vU[��9 {z�'� ���g�p��a{���C���x� �:�Sz��b��;��^�[r����4ZMI�Z��]ڶ2l�eH6bs8�q�DTg�1�~���s!xW�f헂y�n��X�Y��8��n9O�W��`�-�0�k=��b�%]�'&.�p`@���N3���>�$%����FR��b���I����I�zn����e-�!���ڛh��KMʘ4y����B�P-YSG:��Y��ώ�2�өޑ�d:W��K��n7��|����fd�}�"S��>lR�C�;c��Y2����r��n.��h���#����W>���0�.����������'��?>(�?�?����%���!�YT��?��;������C�?��C���O��ׄJ�!���A�4�s3F����>��B��<�G��n�A�I�x!����Y?���
����_�?��W��z��*��e������h$�g�,腹�%ktj1ї�_{��,V�.饑n���w��(��vCI�,��I'Յ�ߌ/#]z-y�;��Bo���k9�>NmZ0��V�p�'�����S	>��ou�J�ߡ������H��� �����0�W���I �E �����$y����_E��������v0"���4�������������m��<��#�q�5��%�pI������wX�2�������J��gf�o�a?3�}kec�8�]ck<<�cF|ܩ�<�������ϒE�Wg�1Fi�ę�d���́U�x�t�ζ����НO}]�[��N��<��
�7mNˍ�`�z�ziǅ�t�g�t��r���۵���ƹ���󏜤I��V���e;
5����r�5��th�?�OeǢ���f�t�[,&��.p��������b�58Ec"{;v��p�g�X�mFgӍٽ��V�f����ml22:O.2-p���E�ǲ+
�����ߚP�����Q���[����$AA�kM���a5�P�?��� ����7���7�C������: I@����
����P9�?=  Q�?������ ��B�/��B�o�����8�*����c~��u�N�cTq��S��P�W���������U����-���������5�?�C�������x���� ��Q#����k����/0�Q	����U����?А�P	 �� ��_=��S@B�w�/�T�l����?��C�����������ZH@����@C�C%��������?迚��C���?��C����_����H���h���� ��� ������?V�_��0�_�����	��l������J�����@������ ��0����������#�?�_@@���K~H���5 ��ϭ�P�����PP����� �86��!�S8?�h�
4IE�����C��C��9_������G}�_���K@�_�T����Z�GW�/��s�8��@�6^�7o��b׊^O�Ӥ)$��ż�8�mb���z}Z��(,���%���hʢ8ܟ��r�af�����\��y�6�(���ʽXC�´��:d;���x�����bSq����q�hI�"5�o��݋��G(��!��>�|�?���[+P��C�W�����������Z��f|B���P�Շ_Y�B�`΍C�)Z���a�Foɝ�`V����E·���[�K��D��}��f٤�����,Yk>Y��y�|-��Ĺ����(�a�\L�s[�v�2�Sd֌
�ҵ���.�1��{+и�ߝ��oE@��������7 ��/������_���_�������X���/�#�����5����k�R7Q�X޳[{b��/�V���V���߳��I;E�$�Md���ޒ�Ge=w�ʜ��PN+a��vg�1�!hl��q�u�Y8�����c��X���d�bY�ݜ�M��b6�Kz�w|37�i��k�q�坾e�=]:�6�o�-�0��ga/�jK���ĥh`�.�I_�4�x���HR�(�n$��X�y̜�)���������h���u�s���X\H"�L*�g��o�F���;{s�x�����D҆�El���j�,^��� �i�u&L#:�Us��ng�����I�O��h��-������/K{��p�¡�[>����[�������J�B�G��?a��|���)�F��E������I��W��ĉ��/�_����\O��@U��?�p��W�g������#����-��0O+�N�h�ԛ-|ʸ�����?Z�h������Ҵh?;n��W��J��{��0�œ函�܏����Y�����Kߐ��rx�.o��-��sl��)�8����u5$�����-e��P��Fή큊}=ި�^m�L�sq>&��g�ZL�e��-
��l2ҡG���u�ѢM�K�xJ0�\�S�/&��n��OVޓ��O_ڹ��e-�x����8x����v�OY��!?}&fJl%�,qno�쨆d��e�G�0�V�=5;�XF�9T��ʧ�����Q�T1��E/�y���.c�#��Fc�s��D8����$�݈�XJܦ/�y��MP{>X%�M�^_�ǂ�W�}����^���c�����[��\��KP~��y�&}aN��}�fCa�����?��M	s��6dB<
��f�G���~����`��������b�;�A�S��~:
;y���0�|F.<)�2�/W��V��ȕ�Z����⣿�7����`���(�?���������?8�������������*�k�_����7�O;𧾓'�@_L�N��<���|�Z�/,Z_�Ԃy��n�>�o�u����f�ao��&��x���������YTr�;�T�wde��P�A�ZZ����I�	��op-�v�x��YQ�Q�g��p�h1���r�iu�D˺��퇽��{�������&��f���ݐG�;��t'j���L[v���tU�:����ItY&�p�f3"p'�p�jҿ�(1�M+߬�"���o5��:�sK�ͅ���:jx�mo�-�t3Ԍ���_4n���}�����G�?��[	*��3>�a��<�Ss�$o���>b�(��>������W0�	��I��>C������������Q	~���갛�MDF��;灃�u��ƙ�{\)��*ZgV;����e�M�`�-�����������(��*������{�����U|����/���$�����������s���AU��������H��+�k����|=�њv���n,���|������>�!����!i/����}l�����Gec.^B��"��(�J��b.Ջ��.�:�>�=?��{���&�����+����]�v�0{��`����c�� ����������I'�L:���������p�SuNU��%���x��¾u��e�
{Z�r)L�O�)�+c��u�����^�y8i��rG�ډ����4:�T���hV�z^�j5��j�v��5>UW{+�%�ͬL������+��rE�Zןn[���(�e	M!���(_������/�>KQ�&�/8�͡��N�èN�v�;k{W�ǋmݑԦ�`�8ܪ#GR��U��~z�^W]M}W7'����F�V��y k}~�ab�V����5�ڡ���TLI�)�J�������X��J#)�H]�/i���|�_&�uk�o��Ʉ,�S�?�����_��BG�����#��u�'_���L��O����O������~T���C ��������0�����
��\��W��R����L��oP��A�7���ߏ��/���J������z��!��φ\�?U��fD6��=BN ��G��7�a�7P��y\������������?`���@��P=������������9���������?0$���� ���������1������������_.��xU��?2"�!�ȅ�U�!����	P��?@��� ��`�em�A]����_.���������ȅ�U�!������ ����@;�����dJ�/r�G���m��B��� �+�����\�����������_ra���� �����Q���� �����<�����a���ȅ��MQi��9��e�湹a�i�1m}nK�e�%�2δm���[X�"�$_�H�}��[��'�_����φW����R�����_�	�,4Ŧ"�J�ɔӿIz~��5Q!�<6��:w�Xܩ[$+�q M����t��i��WhW�#'ޓ����	���Aӳ�-�>j�a�.��a)"f�~h3�h��$k�1��z�&�׬�w;NU�9���W�x�6��d�z{P^��@s?�{W���sF����T���Y�<����?t�A�!�(��򅏩���<�?�������;MZ�U{zLLDK�z!)�V8NZ����%~W�;g�����h՞�ڃ��0C�Gn��5lX��a�pD���X��;�U+�Ķn�.V��1VV��R{��^)�C4�H?z�o%�����7�G3��oD.� ����_���_0����������?��/�X����k���-'�A��z�.�\E�������w��>�bE��3�
����(�>l�^��	�*�M�7�$ɶ����[���X7F��M
|I����Nƅ-��;����d�<�t�ޣ�͵>�zW�UJQ�vX��4*�)0����)��_�O�\(_~&'�*v��S�B2��v��+-8�$�Ij����MY���F��ɇ������
�,P���r��GQ]Ŭ6�v���v9\X�ͦ2��A���X�0�Z:�(	������o���1��;p\�6Ro���k��6�k�`�Q,�Bŏ���w�`��������?�F��@�G�B���_<�d���/^���>=�������&���gA�� �����P7�����\���?0��	����"�����G��̍���̈́<�?T�̞���k�?�� ������#��_ra�Q7������� ������˅����ȍ���Hȅ��]��R���	_��8��?��j\ڷ�+v��%�	7�ͫ�}�m���T���	���qN���-�w���q�2��~�S?�7��N���%������2���-�[t�~�+��j��q�*AǪ.�X��0�}}^�P���T�i��n��̭/LN�6�eF��ć#D%{|�l��㪁6:��bߚ�����������qE�p\ah+iT��XW���:�ceZ�����NW'�����܉u\u&�A��fD�k�3�I[���D7ڬ����ӣ6��: �nŦ���Yfmf{�1V�C�js�'£�/V�3`��������{�8궸G���o�/����ȓ�?��Q�LɅ������ ��������_h�������8ꦸK���o�/�ϒ���ȑ��� ~4���!�_��+�s������v��k�X��Ri-gМ���������Dq^�'Z{s�[����%M��r ��?>� ��ѶZ�C���uzQ/��$8�״Y/h���>mћ���VD`j��KT�hL�ޢY-ڬjE.io���,�dc��q vN�+9 �9	��r z�����ׅEY�.�
�J��/,��4l��G]XT���k�ɲѕT��ʛ��j�آ\V��jgi�$�-��
�=����Xx?�������n����2���ap�-q�����_��Hݨ�X�ς��?SfxS/���^.�ּH�͒�K�4M��K�6��m��e�U.�����G?����Ƀ��Z�����{��9�g|�e��ј�����4�Z:����d�kk��jM�r�e��c��Oh��w
f�r�8��D�;g�^cʊU�E�u����5�Tr���4�h�{P��|\#f�D��P�R��!��x���<��P�H���"P����C��:r��������`��n��$��:����w��bY5:�&s�+F/Ŗ�o5�j��N�@Lܸ�}����td��������;�YRB5�c�c_��8�= �ǖw�a�Yq[1L���Y�Qp�$�Ȟ<��������by��,@���:, ��\�A�2 �� ��`��?��?`�!����Cė����s���_ca���wl�.��q<ܒ�UH����{����߷� `/��(��h��e.��z� �|P��$j���n��E��[Tj>��Q4��9�?	�M���C��ꍺD�Q�J�Bk��KI\�>5󰳝'�BR�>�y�ӵ��d*��aMH�c��"t�U1iJ��`�,J���'�a=(�/ZIV%�8�m�/��D�XeW��.�Rz�:Ho��l��M��Ԑ���ۖ�E�"MŢ!�t��լV��?RN��[r=�kgvl��OT��o40Fb��*2�qc����^��hma�k3�;N�U��ɿ��������7v�z���gA�I&��>����?.ݹcyx��
����;�_?����&U�C��1^Ğ*������0���Kg\�.�Ň���зݵ�K�wN�b*(��Dn�?��8����7W������l4�����B�<k�r()���~spx}P��fz��/��
�����|>�?��>��$�>my�_�_���X����I��,�����-0��|pc��p���������Ÿ�^�����ͣG,�b��ڟ?�����7wah�{���2c?<b���_���s��_���7V��7Q�����Þ$�/���������A2O_�GŞ>�[z���}x�1l����y���?��;���xܬ�x���]�?��י�i��~�׎����c����czB��\��������"<Y���<��|�JT�����Q���OE�?z���)���_�{���o�v�
��̅���ۭ}Ǣ�e�5=��H^~�gٻ\sz�����~�P����_����!|��O�_<ɒ��~.���&��$�xQ�[B}>Y�w�?:���_]��'W��bR�'���r�}�ߑڭ��<uTW'qNB�EgỬ?��7�wx���Y�O����ҟ�����H<>�e?                           |_��� � 