export interface LetterDetails {
  senderName: string;
  senderAddress: string;
  senderCity: string;
  contractNumber?: string;
  serviceName: string;
  recipientEntity: string;
  recipientAddress: string;
  reason: 'echeance_chatel' | 'hausse_tarif' | 'sans_engagement' | 'motif_legitime';
  date?: string;
}

export function generateCancellationLetter(details: LetterDetails): string {
  const today = details.date || new Date().toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  });

  let reasonParagraph = '';
  let legalRef = '';

  switch (details.reason) {
    case 'echeance_chatel':
      legalRef = 'Objet : Résiliation de contrat à échéance — Application de la Loi Chatel (Art. L. 215-1 du Code de la consommation)';
      reasonParagraph = `Conformément aux dispositions de l'article L. 215-1 du Code de la consommation (Loi Chatel), je vous informe par la présente de ma décision de ne pas renouveler mon abonnement et d'y mettre un terme définitif à sa date d'échéance.`;
      break;

    case 'hausse_tarif':
      legalRef = 'Objet : Résiliation pour modification unilatérale des conditions tarifaires (Art. L. 224-33 du Code de la consommation)';
      reasonParagraph = `Faisant suite à la notification d'augmentation de vos tarifs / modification des conditions contractuelles, je vous informe par la présente de mon refus de ces nouvelles conditions et de ma volonté de résilier mon contrat sans pénalité ni frais, conformément à l'article L. 224-33 du Code de la consommation.`;
      break;

    case 'motif_legitime':
      legalRef = 'Objet : Résiliation anticipée pour motif légitime';
      reasonParagraph = `En raison d'un changement de situation constitutif d'un motif légitime (déménagement en zone non éligible / force majeure), je vous notifie par la présente la résiliation sans indemnité de mon abonnement, pièces justificatives jointes.`;
      break;

    case 'sans_engagement':
    default:
      legalRef = 'Objet : Demande de résiliation d\'abonnement sans engagement';
      reasonParagraph = `Je vous informe par la présente de ma décision de résilier mon abonnement sans engagement souscrit auprès de vos services, avec effet à la fin de la période de facturation en cours.`;
      break;
  }

  const contractLine = details.contractNumber
    ? `\nRéférence / Numéro d'abonné : ${details.contractNumber}`
    : '';

  return `${details.senderName}
${details.senderAddress}
${details.senderCity}

À l'attention du :
${details.recipientEntity}
${details.recipientAddress}

Fait le ${today}

${legalRef}${contractLine}

Madame, Monsieur,

${reasonParagraph}

Je vous remercie de bien vouloir me confirmer par écrit (courrier ou courrier électronique) la bonne prise en compte de ma demande de résiliation ainsi que la date effective de clôture de mes accès.

Par ailleurs, je vous demande d'interrompre tout prélèvement automatique sur mon compte bancaire à compter de cette date effective.

Dans cette attente, je vous prie d'agréer, Madame, Monsieur, l'expression de mes salutations distinguées.


${details.senderName}`;
}
