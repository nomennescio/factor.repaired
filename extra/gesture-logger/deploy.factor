USING: tools.deploy.config ;
V{
    { deploy-ui? t }
    { deploy-io 1 }
    { deploy-reflection 3 }
    { deploy-compiler? t }
    { deploy-math? t }
    { deploy-word-props? f }
    { deploy-c-types? f }
    { "stop-after-last-window?" t }
    { "bundle-name" "Gesture Logger.app" }
}
