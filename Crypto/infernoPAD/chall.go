package main

import (
    "crypto/rand"
    "fmt"
    "math/big"
    "os"
)

func randomPrime(bits int) (*big.Int, error) {
    return rand.Prime(rand.Reader, bits)
}

func randInt(max *big.Int) (*big.Int, error) {
    n, err := rand.Int(rand.Reader, max)
    if err != nil {
        return nil, err
    }
    return n, nil
}

func main() {
    p, err := randomPrime(1024)
    if err != nil {
        panic(err)
    }
    
    q, err := randomPrime(1024)
    if err != nil {
        panic(err)
    }
    
    max := new(big.Int).Exp(big.NewInt(2), big.NewInt(1024), nil)
    a, err := randInt(max)
    if err != nil {
        panic(err)
    }
    
    b, err := randInt(max)
    if err != nil {
        panic(err)
    }
    
    n := new(big.Int).Mul(p, q)
    e := big.NewInt(65537)
    
    flag, err := os.ReadFile("flag.txt")
    if err != nil {
        panic(err)
    }
    
    padding := make([]byte, 128-len(flag))
    _, err = rand.Read(padding)
    if err != nil {
        panic(err)
    }
    
    paddedFlag := append(flag, padding...)
    
    m := new(big.Int).SetBytes(paddedFlag)
    
    if m.Cmp(n) >= 0 {
        panic("m is not less than n")
    }
    
    c := new(big.Int).Exp(m, e, n)
    
    x := new(big.Int).Mul(b, q)
    x.Add(x, p)
    
    y := new(big.Int).Mul(a, p)
    y.Add(y, q)
    
    fmt.Println("c =", c)
    fmt.Println("n =", n)
    fmt.Println("x =", x)
    fmt.Println("y =", y)
}