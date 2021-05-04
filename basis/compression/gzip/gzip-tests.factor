USING: compression.gzip compression.inflate tools.test ;

{ B{
    1 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 122 121 94 119
    239 237 227 88 16 16 10 5 16 17 26 172 3 20 19 245 22 54 55
    70 245 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 139 138 112 127 12 6 234 132 254 250 9
    24 16 19 38 182 25 27 40 154 2 240 239 235 25 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    163 163 154 57 223 218 192 128 6 4 39 87 13 9 22 63 245 239
    239 242 240 240 242 243 4 17 17 25 21 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 223 219
    197 140 26 21 26 221 108 117 136 170 0 0 0 0 0 0 0 194 148
    147 138 6 4 4 5 4 33 176 175 161 5 80 81 95 251 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 122 121 105 33 246 246 234 80 241 240
    226 77 28 25 4 58 29 30 68 108 0 0 0 0 0 0 0 0 0 0 0 0 108
    109 118 250 2 24 24 39 230 225 221 203 107 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 103 102 80 101 249 245 214 208 13 6 240 142
    44 37 29 65 11 13 22 250 11 15 30 180 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 1 200 201 196 1 208 195 176 132 224 223 207 50
    253 6 15 181 251 253 0 6 240 241 239 77 14 10 246 64 33 24
    13 0 7 252 20 0 247 1 249 0 241 253 1 205 129 132 173 52
    124 123 107 32 17 16 6 15 115 117 143 209 0 0 0 0 1 255 255
    255 0 0 0 0 0 128 118 95 119 221 222 204 136 1 3 0 0 22 27
    35 0 249 239 239 0 30 22 3 0 247 4 18 0 250 248 247 0 29 26
    31 222 239 249 6 164 241 241 230 48 19 19 28 209 29 30 35
    154 87 88 109 228 1 255 255 255 0 0 0 0 0 0 0 0 0 136 136
    116 39 227 224 218 110 245 245 242 61 238 238 237 36 11 1
    254 9 32 37 20 213 7 14 40 151 2 0 246 36 6 8 20 210 8 8 5
    4 33 32 41 184 10 11 17 232 69 70 80 251 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255 
    255 255 0 107 104 82 144 88 81 34 255 162 159 134 122 255
    255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 195 194
    184 2 255 255 255 0 255 255 255 0 0 255 255 255 0 255 255
    255 0 255 255 255 0 255 255 255 0 255 255 255 0 174 171 167
    15 102 99 63 233 132 129 99 133 255 255 255 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255
    255 255 0 255 255 255 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    119 119 116 4 240 239 217 143 28 28 30 228 34 36 45 232 0 0
    0 0 0 0 0 0 38 38 38 4 28 28 28 2 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 4 0 0 0 0 0 0 0 0 33 33 33 3 38 38 38 9 243 243 243
    252 14 12 44 24 233 235 4 89 250 251 216 126 92 91 76 241 8
    9 21 235 69 69 70 2 250 250 249 214 0 0 0 223 0 0 0 0 0 0 0
    0 0 0 0 0 2 0 0 0 0 0 0 0 0 247 247 247 255 25 25 25 11 45
    46 48 26 239 239 251 219 3 4 1 114 233 236 1 254 21 21 20
    113 12 11 2 54 1 2 2 215 206 206 206 230 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 1 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 46 46
    47 8 56 56 49 70 23 21 9 145 237 239 248 180 247 247 2 148
    225 225 224 234 241 241 240 248 205 205 205 247 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 255 255 255 0 255 255 255 0 255 255
    255 0 255 255 255 0 255 255 255 0 255 255 255 0 107 106 96
    75 90 89 73 75 255 255 255 0 255 255 255 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255
    255 255 0
    }
}  
[ B{
    1 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 122 121 94 119
    239 237 227 88 16 16 10 5 16 17 26 172 3 20 19 245 22 54 55
    70 245 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 139 138 112 127 12 6 234 132 254 250 9
    24 16 19 38 182 25 27 40 154 2 240 239 235 25 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    163 163 154 57 223 218 192 128 6 4 39 87 13 9 22 63 245 239
    239 242 240 240 242 243 4 17 17 25 21 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 223 219
    197 140 26 21 26 221 108 117 136 170 0 0 0 0 0 0 0 194 148
    147 138 6 4 4 5 4 33 176 175 161 5 80 81 95 251 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 122 121 105 33 246 246 234 80 241 240
    226 77 28 25 4 58 29 30 68 108 0 0 0 0 0 0 0 0 0 0 0 0 108
    109 118 250 2 24 24 39 230 225 221 203 107 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 103 102 80 101 249 245 214 208 13 6 240 142
    44 37 29 65 11 13 22 250 11 15 30 180 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 1 200 201 196 1 208 195 176 132 224 223 207 50
    253 6 15 181 251 253 0 6 240 241 239 77 14 10 246 64 33 24
    13 0 7 252 20 0 247 1 249 0 241 253 1 205 129 132 173 52
    124 123 107 32 17 16 6 15 115 117 143 209 0 0 0 0 1 255 255
    255 0 0 0 0 0 128 118 95 119 221 222 204 136 1 3 0 0 22 27
    35 0 249 239 239 0 30 22 3 0 247 4 18 0 250 248 247 0 29 26
    31 222 239 249 6 164 241 241 230 48 19 19 28 209 29 30 35
    154 87 88 109 228 1 255 255 255 0 0 0 0 0 0 0 0 0 136 136
    116 39 227 224 218 110 245 245 242 61 238 238 237 36 11 1
    254 9 32 37 20 213 7 14 40 151 2 0 246 36 6 8 20 210 8 8 5
    4 33 32 41 184 10 11 17 232 69 70 80 251 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255 
    255 255 0 107 104 82 144 88 81 34 255 162 159 134 122 255
    255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 195 194
    184 2 255 255 255 0 255 255 255 0 0 255 255 255 0 255 255
    255 0 255 255 255 0 255 255 255 0 255 255 255 0 174 171 167
    15 102 99 63 233 132 129 99 133 255 255 255 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255
    255 255 0 255 255 255 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    119 119 116 4 240 239 217 143 28 28 30 228 34 36 45 232 0 0
    0 0 0 0 0 0 38 38 38 4 28 28 28 2 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 4 0 0 0 0 0 0 0 0 33 33 33 3 38 38 38 9 243 243 243
    252 14 12 44 24 233 235 4 89 250 251 216 126 92 91 76 241 8
    9 21 235 69 69 70 2 250 250 249 214 0 0 0 223 0 0 0 0 0 0 0
    0 0 0 0 0 2 0 0 0 0 0 0 0 0 247 247 247 255 25 25 25 11 45
    46 48 26 239 239 251 219 3 4 1 114 233 236 1 254 21 21 20
    113 12 11 2 54 1 2 2 215 206 206 206 230 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 1 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 46 46
    47 8 56 56 49 70 23 21 9 145 237 239 248 180 247 247 2 148
    225 225 224 234 241 241 240 248 205 205 205 247 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 255 255 255 0 255 255 255 0 255 255
    255 0 255 255 255 0 255 255 255 0 255 255 255 0 107 106 96
    75 90 89 73 75 255 255 255 0 255 255 255 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255
    255 255 0
    }
   compress-dynamic gzip-inflate 
] unit-test 

{ B{
    1 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 122 121 94 119
    239 237 227 88 16 16 10 5 16 17 26 172 3 20 19 245 22 54 55
    70 245 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 139 138 112 127 12 6 234 132 254 250 9
    24 16 19 38 182 25 27 40 154 2 240 239 235 25 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    163 163 154 57 223 218 192 128 6 4 39 87 13 9 22 63 245 239
    239 242 240 240 242 243 4 17 17 25 21 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 223 219
    197 140 26 21 26 221 108 117 136 170 0 0 0 0 0 0 0 194 148
    147 138 6 4 4 5 4 33 176 175 161 5 80 81 95 251 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 122 121 105 33 246 246 234 80 241 240
    226 77 28 25 4 58 29 30 68 108 0 0 0 0 0 0 0 0 0 0 0 0 108
    109 118 250 2 24 24 39 230 225 221 203 107 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 103 102 80 101 249 245 214 208 13 6 240 142
    44 37 29 65 11 13 22 250 11 15 30 180 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 1 200 201 196 1 208 195 176 132 224 223 207 50
    253 6 15 181 251 253 0 6 240 241 239 77 14 10 246 64 33 24
    13 0 7 252 20 0 247 1 249 0 241 253 1 205 129 132 173 52
    124 123 107 32 17 16 6 15 115 117 143 209 0 0 0 0 1 255 255
    255 0 0 0 0 0 128 118 95 119 221 222 204 136 1 3 0 0 22 27
    35 0 249 239 239 0 30 22 3 0 247 4 18 0 250 248 247 0 29 26
    31 222 239 249 6 164 241 241 230 48 19 19 28 209 29 30 35
    154 87 88 109 228 1 255 255 255 0 0 0 0 0 0 0 0 0 136 136
    116 39 227 224 218 110 245 245 242 61 238 238 237 36 11 1
    254 9 32 37 20 213 7 14 40 151 2 0 246 36 6 8 20 210 8 8 5
    4 33 32 41 184 10 11 17 232 69 70 80 251 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255 
    255 255 0 107 104 82 144 88 81 34 255 162 159 134 122 255
    255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 195 194
    184 2 255 255 255 0 255 255 255 0 0 255 255 255 0 255 255
    255 0 255 255 255 0 255 255 255 0 255 255 255 0 174 171 167
    15 102 99 63 233 132 129 99 133 255 255 255 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255
    255 255 0 255 255 255 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    119 119 116 4 240 239 217 143 28 28 30 228 34 36 45 232 0 0
    0 0 0 0 0 0 38 38 38 4 28 28 28 2 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 4 0 0 0 0 0 0 0 0 33 33 33 3 38 38 38 9 243 243 243
    252 14 12 44 24 233 235 4 89 250 251 216 126 92 91 76 241 8
    9 21 235 69 69 70 2 250 250 249 214 0 0 0 223 0 0 0 0 0 0 0
    0 0 0 0 0 2 0 0 0 0 0 0 0 0 247 247 247 255 25 25 25 11 45
    46 48 26 239 239 251 219 3 4 1 114 233 236 1 254 21 21 20
    113 12 11 2 54 1 2 2 215 206 206 206 230 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 1 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 46 46
    47 8 56 56 49 70 23 21 9 145 237 239 248 180 247 247 2 148
    225 225 224 234 241 241 240 248 205 205 205 247 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 255 255 255 0 255 255 255 0 255 255
    255 0 255 255 255 0 255 255 255 0 255 255 255 0 107 106 96
    75 90 89 73 75 255 255 255 0 255 255 255 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255
    255 255 0
    }
}  
[ B{
    1 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 122 121 94 119
    239 237 227 88 16 16 10 5 16 17 26 172 3 20 19 245 22 54 55
    70 245 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 139 138 112 127 12 6 234 132 254 250 9
    24 16 19 38 182 25 27 40 154 2 240 239 235 25 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    163 163 154 57 223 218 192 128 6 4 39 87 13 9 22 63 245 239
    239 242 240 240 242 243 4 17 17 25 21 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 223 219
    197 140 26 21 26 221 108 117 136 170 0 0 0 0 0 0 0 194 148
    147 138 6 4 4 5 4 33 176 175 161 5 80 81 95 251 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 122 121 105 33 246 246 234 80 241 240
    226 77 28 25 4 58 29 30 68 108 0 0 0 0 0 0 0 0 0 0 0 0 108
    109 118 250 2 24 24 39 230 225 221 203 107 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 103 102 80 101 249 245 214 208 13 6 240 142
    44 37 29 65 11 13 22 250 11 15 30 180 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 1 200 201 196 1 208 195 176 132 224 223 207 50
    253 6 15 181 251 253 0 6 240 241 239 77 14 10 246 64 33 24
    13 0 7 252 20 0 247 1 249 0 241 253 1 205 129 132 173 52
    124 123 107 32 17 16 6 15 115 117 143 209 0 0 0 0 1 255 255
    255 0 0 0 0 0 128 118 95 119 221 222 204 136 1 3 0 0 22 27
    35 0 249 239 239 0 30 22 3 0 247 4 18 0 250 248 247 0 29 26
    31 222 239 249 6 164 241 241 230 48 19 19 28 209 29 30 35
    154 87 88 109 228 1 255 255 255 0 0 0 0 0 0 0 0 0 136 136
    116 39 227 224 218 110 245 245 242 61 238 238 237 36 11 1
    254 9 32 37 20 213 7 14 40 151 2 0 246 36 6 8 20 210 8 8 5
    4 33 32 41 184 10 11 17 232 69 70 80 251 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255 
    255 255 0 107 104 82 144 88 81 34 255 162 159 134 122 255
    255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 195 194
    184 2 255 255 255 0 255 255 255 0 0 255 255 255 0 255 255
    255 0 255 255 255 0 255 255 255 0 255 255 255 0 174 171 167
    15 102 99 63 233 132 129 99 133 255 255 255 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255
    255 255 0 255 255 255 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    119 119 116 4 240 239 217 143 28 28 30 228 34 36 45 232 0 0
    0 0 0 0 0 0 38 38 38 4 28 28 28 2 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 4 0 0 0 0 0 0 0 0 33 33 33 3 38 38 38 9 243 243 243
    252 14 12 44 24 233 235 4 89 250 251 216 126 92 91 76 241 8
    9 21 235 69 69 70 2 250 250 249 214 0 0 0 223 0 0 0 0 0 0 0
    0 0 0 0 0 2 0 0 0 0 0 0 0 0 247 247 247 255 25 25 25 11 45
    46 48 26 239 239 251 219 3 4 1 114 233 236 1 254 21 21 20
    113 12 11 2 54 1 2 2 215 206 206 206 230 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 1 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 46 46
    47 8 56 56 49 70 23 21 9 145 237 239 248 180 247 247 2 148
    225 225 224 234 241 241 240 248 205 205 205 247 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 255 255 255 0 255 255 255 0 255 255
    255 0 255 255 255 0 255 255 255 0 255 255 255 0 107 106 96
    75 90 89 73 75 255 255 255 0 255 255 255 0 255 255 255 0
    255 255 255 0 255 255 255 0 255 255 255 0 255 255 255 0 255
    255 255 0
    }
   compress-fixed gzip-inflate 
] unit-test 
