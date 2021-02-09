# AcessoBio SDK - iOS

Esta biblioteca visa implementar a tecnologia Acesso para captura inteligente e prova de vida sob a plataforma Android.

## Começando

Siga atentamente as instruções abaixo para a implementação bem-sucedida da ferramenta.

### Pré requisitos

 - Xcode - IDE oficial de desenvolvimento Apple. Versão 9 ou superior
 - CocoaPods - Gerenciador de bibiotecas para IDE

Siga a documentação [cocoapods](https://cocoapods.org/) para instalar o gerenciador em sua maquina caso ainda a possua. 


Caso ainda não possua as permissões para o uso de câmera em seu projeto, nao esqueça de adicionar antes de compilar o sua aplicação. Segue o exemplo: 

```
<key>NSCameraUsageDescription</key>
<string>Camera usage description</string>
```

### Instalando

Recomendamos o uso do cocoapods para o desenvolvimento da aplicação. 

- Abra o terminal e navegue até o diretório raiz da aplicação.
- Na raiz, digite no terminal: 

```
pod init 
```

![](https://media.giphy.com/media/QCCiKSwfM8wuyYPaOI/giphy.gif)

- Um arquivo Podfile será criado em seu diretório.

![](https://media.giphy.com/media/SsgTAziSaHmH84BASS/giphy.gif)


- Abra o mesmo e adicione:
```
  pod ‘AcessoBio’, :git => 'https://github.com/acesso-io/acessobio-ios'
```
ou 
```
  pod ‘AcessoBio’, :git => 'https://github.com/acesso-io/acessobio-ios'
, :tag => ‘1.2.1’
```
última versão estável.

![](https://media.giphy.com/media/eK6aukS7LdEOv0NFgC/giphy.gif)

Por último, volte ao terminal e adicione a seguinte linha: 

```
pod install
```
![](https://media.giphy.com/media/f7Z6XiHwXK1a7lq8VT/giphy.gif)


Pronto! A nossa SDK já esta adicionada e pronta para uso. 

## Manuseio

Importar, inicializar e receber os callbacks básicos é muito simples, siga os passos abaixo:

- Abra o seu arquivo *.h* que deseja utilizar nossa ferramenta importe e implemente nossa classe: 

```objc
#import <AcessoBio/AcessoBioManager.h>

@interface ViewController : UIViewController <AcessoBioDelegate>
```

- No arquivo *.m* instancie e chame a abertura do AcessoBioManager:

```objc

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc] initWithViewController:self
    url:{URL_SERVICE} apikey:{API_KEY} token:{TOKEN}];
    
}

```

Note que ao instânciar a classe AcessoBioManager, temos alguns parâmetros a serem inputados no construtor, tais quais são: 
- ``URL_SERVICE``: url de serviço. Ex: ``https://www2.acesso.io/NOME_DA_SUA_INSTANCIA/services/v3/acessoservice.svc`` - (A mesma utilizada em todos os demais endpoints de nossos serviços)
- ``API_KEY``: apykey referente a sua instância. - (A mesma utilizada em todos os demais endpoints de nossos serviços)
- ``TOKEN``: token que é fornecido através de nossos serviços de autenticação. 

### Câmera Inteligente

Para realizar a captura com nossa câmera inteligente, implemente o método ``[acessoBioManager openCameraFace];``. Seu código deve parecer com isto: 

```objc

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc] initWithViewController:self
    url:{URL_SERVICE} apikey:{API_KEY} token:{TOKEN}];
    [acessoBioManager openCameraFace];
    
    
}

```

Nossa ferramenta também permite a criação de processo e verificação de prova de vida ao mesmo tempo e simuntâneamente, simplificando e facilitando ambas as validações em apenas com um método.  

```objc

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc] initWithViewController:self
    url:{URL_SERVICE} apikey:{API_KEY} token:{TOKEN}];
    [acessoBioManager openCameraFaceWithCreateProcess:{CODE} name:{NAME} gender:{GENDER} birthdate:{BIRTHDATE} email:{EMAIL} phone:{PHONE}];
;
    
    
}

```

Ao implementar o método createLivenessX, temos alguns parâmetros a serem inputados no construtor, tais quais são: 
- ``CODE``: CPF do usuário sem caracteres especiais.  
- ``NAME``: Nome do usuário.
- ``GENDER``<_opcional_>: Gênero do usuário - M para masculino e F para feminino.
- ``BIRTHDATE``<_opcional_>: Data de nascimento do usuário.
- ``EMAIL``<_opcional_>: Email do usuário.
- ``PHONE``<_opcional_>: Telefone do usuário sem caracteres especiais.

Pronto, importamos e inicializamos nossa solução... Estamos quase lá!  

Para obter o retorno referente ao resultado de ambos os métodos (``[acessoBioManager openCameraFace];`` - ``[acessoBioManager openCameraFaceWithCreateProcess]``) implemente os seguintes métodos de retorno:

```objc
- (void)onSuccesCameraFace:(CameraFaceResult *)result {
    
    NSLog(@"base64 da foto: %@", result.base64);
    NSLog(@"id do processo: %@", result.processId);
    NSString *processId = result.processId;
    NSString *base64 = result.base64;
    
}

- (void)onErrorCameraFace:(NSString *)error {
    
    NSLog(@"%@", error);

}
```


### Prova de vida

Para realizar a verificação de prova de vida, implemente o método ``[acessoBioManager openLivenessX];``. Seu código deve parecer com isto: 

```objc

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc] initWithViewController:self
    url:{URL_SERVICE} apikey:{API_KEY} token:{TOKEN}];
    [acessoBioManager openLivenessX];
    
}

```

Nossa ferramenta também permite a criação de processo e verificação de prova de vida ao mesmo tempo e simuntâneamente, simplificando e facilitando ambas as validações em apenas com um método.  

```objc

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc] initWithViewController:self
    url:{URL_SERVICE} apikey:{API_KEY} token:{TOKEN}];
    [acessoBioManager openLivenessXWithCreateProcess:{CODE} name:{NAME} gender:{GENDER} birthdate:{BIRTHDATE} email:{EMAIL} phone:{PHONE}];
;
    
    
}

```

Ao implementar o método createLivenessX, temos alguns parâmetros a serem inputados no construtor, tais quais são: 
- ``CODE``: CPF do usuário sem caracteres especiais.  
- ``NAME``: Nome do usuário.
- ``GENDER``<_opcional_>: Gênero do usuário - M para masculino e F para feminino.
- ``BIRTHDATE``<_opcional_>: Data de nascimento do usuário.
- ``EMAIL``<_opcional_>: Email do usuário.
- ``PHONE``<_opcional_>: Telefone do usuário sem caracteres especiais.

Pronto, importamos e inicializamos nossa solução... Estamos quase lá!  

Para obter o retorno referente ao resultado de ambos os métodos (``[acessoBioManager openLivenessX];`` - ``[acessoBioManager openLivenessXWithCreateProcess]``) implemente os seguintes métodos de retorno:

```objc
- (void)onSuccesLivenessX:(LivenessXResult *)result {
    
    NSLog(@"ao vivo? : %d", result.isLiveness);
    NSLog(@"base64 da foto: %@", result.base64);
    NSLog(@"id do processo: %@", result.processId);
    
    BOOL isLiveness = result.isLiveness;
    NSString *processId = result.processId;
    NSString *base64 = result.base64;
    
}

- (void)onErrorLivenessX:(NSString *)error {
    
    NSLog(@"%@", error);

}
```

### Documentos

Nossa SDK conta também com todo o suporte para capturas de documentos que a Acesso oferece de forma muito simples e segura.

Os tipos de documentos que atualmente oferecemos suporte para captura são: 

| Tipo | Enum |
| ------ | ------ |
| RG | DocumentRG |
| RG Frente | DocumentRGFrente |
| RG Verso | DocumentRGVerso |
| CPF | DocumentCPF |
| CNH | DocumentCNH | 

para os métodos: 

| Método | Descrição |
| ------ | ------ |
| Document Capture | Abre o modo captura com as silhuetas adequadas e devolve o base64 do documento. |
| Document Insert | Insere um documento como anexo no processo de biometria. |
| OCR | Extração de dados de documentos como: CNH (Aberta, frente ou verso), RG (Frente ou Verso) e CRM (Frente ou verso). |
| FaceMatch | Verifica se a foto no documento é a mesma pessoa da foto informada. |


### Document Capture 

Para apenas capturar o documento, implemente o método `` acessoBioManager openCameraDocuments:DOCUMENT_TYPE]; ``. Seu código deve parecer com isto: 

```objc

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc] initWithViewController:self
    url:{URL_SERVICE} apikey:{API_KEY} token:{TOKEN}];
    [acessoBioManager openCameraDocuments:{DOCUMENT_TYPE}];
    
}

```

Ao implementar o método openCameraDocument, temos o seguinte parâmetro a ser imputado no construtor: 
- ``DOCUMENT_TYPE``: Enum referente ao tipo de documento, como mencionado acima. (DocumentRG, DocumentRGFrente, DocumentRGVerso, DocumentCPF, DocumentCNH).

Para obter o retorno referente ao resultado do método (``[acessoBioManager openCameraDocuments:DOCUMENT_TYPE];``) implemente os seguintes métodos de retorno:

```objc

- (void)onSuccesCameraDocument:(CameraDocumentResult *)result {
  // result.base64: Base64 do documento  
}

- (void)onErrorCameraDocument:(NSString *)error {
    NSLog(@"%@", error);
}

```

#### OCR

Para fazer a extração dos dados do documento, implemente o método ``[acessoBioManager openCameraDocumentOCR:DOCUMENT_TYPE];``. Seu código deve parecer com isto: 

```objc

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc] initWithViewController:self
    url:{URL_SERVICE} apikey:{API_KEY} token:{TOKEN}];
    [acessoBioManager openCameraDocumentOCR:{DOCUMENT_TYPE}];
    
}

```

 Para obter o retorno referente ao resultado do método (``[acessoBioManager openCameraDocumentOCR:DOCUMENT_TYPE];``) implemente os seguintes métodos de retorno:

```objc

- (void)onSuccessOCR:(OCRResult *)result {
    // OCRResult contém todos os campos que são possíveis ser extraídos
}

- (void)onErrorOCR:(NSString *)error {
    NSLog(@"%@", error);
}

```

#### Face Match

Para verificar se a foto no documento é a mesma pessoa da foto informada, implemente o método ``[acessoBioManager openCameraDocumentFacematch:DOCUMENT_TYPE];``. Seu código deve parecer com isto: 

```objc

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc] initWithViewController:self
    url:{URL_SERVICE} apikey:{API_KEY} token:{TOKEN}];
    [acessoBioManager openCameraDocumentFacematch:{DOCUMENT_TYPE}];
    
}

```

 Para obter o retorno referente ao resultado do método (``[acessoBioManager openCameraDocumentFacematch:DOCUMENT_TYPE];``) implemente os seguintes métodos de retorno:

```objc

- (void)onSuccessFacematch:(FacematchResult *)result {
    // Para obter o status, apenas implemente aqui: result.Status - 0: Reprovado/Desligado 1: Aprovado
}

- (void)onErrorFacematch:(NSString *)error {
    NSLog(@"%@", error);
}

```

### Verificação 1:1 

Nossa SDK conta com o modo de autenticação 1:1, funcionalidade para processos em que um usuário já existente na base do cliente, deseja apenas se autenticar.

A consulta é sempre realizada em base PRÓPRIA, diferente do método 1:N (lê-se 1 para N).responsável pela comparação da biometria facial capturada com a foto cadastrada na base. Para isto, basta implementar o método ``[acessoBioManager facesCompare:{cpf} base64Selfie:(NSString*)base64Selfie];``. Seu código deve parecer com isto: 

```objc

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc] initWithViewController:self
    url:{URL_SERVICE} apikey:{API_KEY} token:{TOKEN}];
    [acessoBioManager facesCompare:{cpf} base64Selfie:(NSString*)base64Selfie];    
}

```
 Para obter o retorno referente ao resultado do método (``[acessoBioManager facesCompare:{cpf} base64Selfie:(NSString*)base64Selfie];``) implemente os seguintes métodos de retorno:
 
 ```objc

- (void)onSuccessFacesCompare:(BOOL)status {
    // Status - 0: Reprovado 1: Aprovado
}

- (void)onErrorFacesCompare:(NSString *)error {
    NSLog(@"%@", error);
}

```

### Customização

Nossa SDK conta com métodos de customização a fim de personalizar a experiência de acordo com o identidade visual de cada cliente! :) 

Segue a lista de métodos que pode ser facilmente implementadas: 

 | Método | Descrição |
| ------ | ------ |
| ``-(void)setColorSilhoutteNeutral: (UIColor *)color`` | Espera uma UIColor como entrada e permite customizar a cor da silhueta no estado neutra. |
| ``-(void)setColorSilhoutteSuccess: (UIColor *)color`` | Espera uma UIColor como entrada e permite customizar a cor da silhueta no estado de correto posicionamento da face. |
| ``-(void)setColorSilhoutteError: (UIColor *)color`` | Espera uma UIColor como entrada e permite customizar a cor da silhueta no estado de incorreto posicionamento da face. |
| ``-(void)setColorBackground: (UIColor *)color`` | Espera uma UIColor como entrada e permite customizar o plano de fundo. |
| ``-(void)setColorBackgroundBoxStatus: (UIColor *)color`` | Espera uma UIColor como entrada e permite customizar o plano de fundo do box de status da captura. |
| ``-(void)setColorTextBoxStatus: (UIColor *)color`` | Espera uma UIColor como entrada e permite customizar o texto inserido no box de status da captura. |
| ``-(void)setColorBackgroundPopupError: (UIColor *)color`` | Espera uma UIColor como entrada e permite customizar o plano de fundo do popup exibido em estados de incorreto posicionamento da face. |
| ``-(void)setColorTextPopupError: (UIColor *)color`` | Espera uma UIColor como entrada e permite customizar os textos inseridos no popup exibido em estados de incorreto posicionamento da face. |
| ``-(void)setColorTitleButtonPopupError: (UIColor *)color`` | Espera uma UIColor como entrada e permite customizar o texto inserido no botão "Tentar novamente" no popup exibido em estados de incorreto posicionamento da face. |
| ``-(void)setColorBackgroundButtonPopupError: (UIColor *)color`` | Espera uma UIColor como entrada e permite customizar a cor do plano de fundo do botão "Tentar novamente" no popup exibido em estados de incorreto posicionamento da face. |
| ``-(void)setImageIconPopupError: (UIColor *)color`` | Espera uma UIImage como entrada e permite customizar a imagem do ícone localizado ao topo do popup exibido em estados de incorreto posicionamento da face. |

Para invocar qualquer um dos métodos acima, basta adicionar a nossa classe manager e fazer a chamada padrão com o método escolhido, segue um exemplo abaixo: 


```objc

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc] initWithViewController:self
    url:{URL_SERVICE} apikey:{API_KEY} token:{TOKEN}];
    [acessoBioManager setColorBackground:[UIColor orangeColor]];
    [acessoBioManager setColorSilhoutteNeutral:[UIColor whiteColor]];
    [acessoBioManager setColorSilhoutteSuccess:[UIColor greenColor]];
    [acessoBioManager setColorSilhoutteError:[UIColor redColor]];

}

```

# Tamanho 

Em análise...

## Projeto de exemplo

* [POC de exemplo em Objetive-C](https://github.com/MatheusDomingos/poc-example-ios) - Projeto de exemplo exibindo como fazer a implementação correta da SDK em Objetive-C. 

* [POC de exemplo em Swift](https://github.com/MatheusDomingos/poc-swift-acessobio) - Projeto de exemplo exibindo como fazer a implementação correta da SDK em Swift. 

## Versionamento

Nós usamos [Github](https://github.com/) para versionar. Para as versões disponíveis, veja as [tags do repositório](https://github.com/acesso-io/livenessX-ios/releases). 

## Autores

* **Lucas Ibiapina** - *Engenheiro Mobile* - [GitHub](https://github.com/lucas-ibiapina)
* **Matheus Domingos** - *Engenheiro Mobile* - [GitHub](https://github.com/MatheusDomingos)


Veja também nossa lista de [contribuidores](https://github.com/acesso-io/livenessX-ios/graphs/contributors) que participaram deste projeto. Para isto, implemente o seguinte código com sua variações de construtor: 


## Licença

Este proje é licenciado pela MIT License - veja [LICENSE.md](LICENSE.md) o arquivo para detalhes

