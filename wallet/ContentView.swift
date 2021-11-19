import SwiftUI
import Solana

class InMemoryAccountStorage: SolanaAccountStorage {
    
    private var _account: Account?
    private var tokenKey: String = "bulochka"
    
    func save(_ account: Account) -> Result<Void, Error> {
        do {
            let data = try JSONEncoder().encode(account)
            UserDefaults.standard.set(data, forKey: tokenKey)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    enum SolanaAccountStorageError: Error {
        case unauthorized
    }
    var account: Result<Account, Error> {
        // Read from the keychain
        guard let data = UserDefaults.standard.data(forKey: tokenKey) else {
            return .failure(SolanaAccountStorageError.unauthorized)
        }
        if let account = try? JSONDecoder().decode(Account.self, from: data) {
            return .success(account)
        }
        return .failure(SolanaAccountStorageError.unauthorized)
    }
    
    func clear() -> Result<Void, Error> {
        _account = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        return .success(())
    }
}

var storage:InMemoryAccountStorage = InMemoryAccountStorage()
let network = NetworkingRouter(endpoint: .devnetSolana)
let solana = Solana(router: network, accountStorage: storage)
let withPhrase = Array(repeating: "bobby", count: 24)
let endpoint: RPCEndpoint = .devnetSolana

var tokens = UserDefaults.standard.data(forKey: "bulochka")

struct ContentView: View {
    init(){
        if (tokens == nil || (tokens?.isEmpty ?? true))  {
            let account = Account(phrase: withPhrase, network: endpoint.network, derivablePath: .default)!
            _=storage.save(account)
        }
    }
    
    var body: some View {

        VStack {
            Button(action: {
                let acc = try? storage.account.get()
                if acc != nil {
                    solana.api.getAccountInfo(account: acc!.publicKey.base58EncodedString, decodedTo: AccountInfo.self) {
                        result in
                        dump(result)
                        print("____________________________________________________________________")
                    }
                    //storage.clear()
                }
                //63U8aTSYkL71o8XPLmwrk8BjgoExFcHoSXa8YkRRgRvS
                
            }) {
                Text("Get Account Info")
                .foregroundColor(Color.white)
            }
            .padding()
            .background(Color.blue)
            
            Button(action: {
                let acc = try? storage.account.get()
                if acc != nil {
                    print("____________________________________________________________________")
                    solana.api.getBalance(account: acc!.publicKey.base58EncodedString, commitment: nil, onComplete: {result in
                        dump(result)
                        print("____________________________________________________________________")
                    })
                    
                }
                
            }) {
                Text("Get wallet Balance")
                .foregroundColor(Color.white)
            }
            .padding()
            .background(Color.blue)
            
            Button(action: {
                let acc = try? storage.account.get()
                if acc != nil {
                    print("____________________________________________________________________")
                    solana.api.requestAirdrop(account: acc!.publicKey.base58EncodedString, lamports: 1000000000, commitment: nil, onComplete: {result in
                        dump(result)
                        print("____________________________________________________________________")
                    })
              }
            }) {
                Text("Add 1 SOL")
                .foregroundColor(Color.white)
            }
            .padding()
            .background(Color.blue)
            
            Button(action: {
                let acc = try? storage.account.get()
                if acc != nil {
                    print("____________________________________________________________________")
                    solana.action.sendSOL(to: "9qX8TcaqpkVYg8T3vBx5WHnEeAFKrXekdyejFKVDHi8F",
                                          amount: 1000000000,
                                          onComplete: {result in dump(result)
                    print("____________________________________________________________________")
                    })
                    
                }
            }) {
                Text("Send 1 SOL")
                .foregroundColor(Color.white)
            }
            .padding()
            .background(Color.blue)

        }
    }
    func joinClub(){
        print("hello dummy")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
