//  HistoireViewController.swift
//  QuizProjet
//
//  Created by Monica Mortelette on 27/03/2024.
//

import UIKit
import AVFoundation
import AVKit

class HistoireViewController: UIViewController {
    
    // déclaration des vaariables
    var questionActuelleIndex = 0
    var questions = [Question]()
    var score = 0
    var essaiNb = 0
    var reponsevraie : AVAudioPlayer?
    var reponsefausse : AVAudioPlayer?
    
    // ajout des outlets
    @IBOutlet weak var question: UILabel!
    @IBOutlet var answers: [UIButton]!
    @IBOutlet weak var rejouer: UIButton!
    @IBOutlet weak var texteFinGame: UILabel!
    @IBOutlet weak var imageFinGame: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadQuestionsFromFile()
        questions.shuffle() // Mélanger les questions
        questionSuivante()
        
        // recuperer le son pour la bonne reponse
        let cheminvraie = Bundle.main.path(forResource: "reponsevraie", ofType: "mp3")
        let adressevraie = URL(fileURLWithPath: cheminvraie!)
        
        do {
            
            reponsevraie = try AVAudioPlayer(contentsOf: adressevraie)
        } catch {
            print("Erreur à l'initialisation du son")
        }
        
        // recuperer le son pour la mauvaise reponse
        let cheminfaux = Bundle.main.path(forResource: "reponsefausse", ofType: "mp3")
        let adressefausse = URL(fileURLWithPath: cheminfaux!)
        
        do {
            
            reponsefausse = try AVAudioPlayer(contentsOf: adressefausse)
        } catch {
            print("Erreur à l'initialisation du son")
        }
        
        // Définir les coins arrondis des boutons
            for button in answers {
                button.layer.cornerRadius = 10 // Choisissez la valeur appropriée pour vos coins arrondis
                button.clipsToBounds = true
            }
        
    }
    
    
    func loadQuestionsFromFile() {
        
        // chargement du fichier json avec toutes les questions
        if let filepath = Bundle.main.path(forResource: "questionsgeographie", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: filepath))
                questions = try JSONDecoder().decode([Question].self, from: jsonData)
            } catch {
                print("Erreur de lecture du fichier JSON :", error)
            }
        } else {
            print("Fichier 'questionsgeographie.json' introuvable.")
        }
    }
    
    
    func questionSuivante() {
        
        //cacher l'animation de fin de partie
        rejouer.isHidden = true
        imageFinGame.isHidden = true
        texteFinGame.isHidden = true
        
        if questionActuelleIndex < questions.count {
            let questionActuelle = questions[questionActuelleIndex]
            question.text = questionActuelle.question
            
            // Mélanger les options de réponse
            let optionMix = questionActuelle.options.shuffled()
            
            //réinitialiser la couleur du texte
            for button in answers {
                button.setTitleColor(UIColor.black, for: .normal)
            }
            
            for (index, option) in optionMix.enumerated() {
                
                // Vérifier si l'index est inférieur au nombre de boutons de réponse
                if index < answers.count {
                    
                    // Afficher l'option de réponse mélangée sur le bouton correspondant
                    answers[index].setTitle(option, for: .normal)
                    answers[index].backgroundColor = nil
                    answers[index].isHidden = false
                } else {
                    
                    // Cacher les boutons restants s'il y a moins de boutons que d'options de réponse (ce qui n'est pas le cas dans notre fichier pour le moment)
                    answers[index].isHidden = true
                }
            }
        } else {
            print("Fin des questions.")
        }
    }

    // Déclarer le minuteur en dehors de toute fonction pour qu'il soit accessible partout dans la classe
    var timer: Timer?

    
    @IBAction func reponse(_ sender: UIButton) {
        let questionActuelle = questions[questionActuelleIndex]
        if sender.titleLabel?.text == questionActuelle.answer {
            
            // Si c'est la bonne réponse, le bouton devient vert et après 0.2 seconde, on passe à la question suivante
            sender.backgroundColor = UIColor(red: 144/255, green: 169/255, blue: 85/255, alpha: 1.0) // vert spécifique
            print("Bonne réponse !")
            
            //jouer le son quand la reponse est bonne
            reponsevraie!.play()
            
            // Augmenter le score en fonction du nombre d'essais
                        switch essaiNb {
                        case 0:
                            score += 3 // Si c'est le premier essai c'est + 3 points
                        case 1:
                            score += 2 // Si c'est le deuxième essai c'est + 2 points
                        case 2:
                            score += 1 // Si c'est le troisième essai c'est + 1 points
                        default:
                            break // Sinon on n'ajoute pas de point
                        }
                        
                        // Réinitialiser le nombre d'essais
                        essaiNb = 0
                        
                        // Afficher le score mis à jour
                        print("Le score du joueur est de : \(score)")
            
            // Arrêter le minuteur s'il est en cours
            timer?.invalidate()
            
            // Démarrer le minuteur pour passer à la question suivante après 0.2 seconde
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                
                // Vérifier s'il reste des questions avant d'incrémenter l'index
                if self.questionActuelleIndex + 1 < self.questions.count {
                    self.questionActuelleIndex += 1
                    self.questionSuivante()
                } else {
                    print("Fin des questions.")
                    
                    // afficher l'animation et l'option de rejouer
                    rejouer.isHidden = false
                    imageFinGame.isHidden = false
                    texteFinGame.isHidden = false
                    texteFinGame.text = "Bravo pour avoir terminé ce quiz ! Votre score final est de \(score). J'espère que vous avez apprécié ce défi et que vous avez enrichi vos connaissances en Histoire Géographie. Si vous êtes prêt pour un nouveau défi, n'hésitez pas à cliquer sur le bouton 'Rejouer' pour tester vos connaissances à nouveau."
                    
                    // cacher les questions et réponses du quizz
                    question.isHidden = true
                    for button in self.answers {
                        button.isHidden = true
                    }
                }
            }
            
        } else {
            
            // Si c'est la mauvaise réponse, le bouton devient rouge, le nombre d'essais est incrémenté et on reste sur cette question pour que le joueur retente
            sender.backgroundColor = UIColor(red: 140/255, green: 47/255, blue: 57/255, alpha: 1.0)  // rouge spécifique
            sender.setTitleColor(UIColor.white, for: .normal)
            print("Mauvaise réponse ! La bonne réponse est \(questionActuelle.answer)")
            essaiNb += 1

            //jouer le son quand la reponse est mauvaise
            reponsefausse!.play()
        }
    }


    struct Question: Codable {
        let question: String
        let options: [String]
        let answer: String
    }
}
