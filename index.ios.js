import { NativeModules } from 'react-native'

const { EZUIKitManage } = NativeModules

export default class EZUIKit {
    static setAppKeyAndAccessToken(appKey, accessToken, ezopenUrl, callBack) {
        console.log('1111111111', EZUIKitManage)
        if (EZUIKitManage) {
            EZUIKitManage.setAppKey(
              '5aa50013b75f4801a3b71d3054f11e06', 
              'at.9tqv9tkg3290ykvn6g89f17m52y2cret-58eq0rmpwu-0k2vyuu-kfknuz0xo',
              'ezopen://open.ys7.com/574998346/1.hd.live',
              () => {
              })
          }
    }
}
