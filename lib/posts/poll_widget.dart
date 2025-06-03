import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/posts/post_model.dart';

class PollWidget extends StatefulWidget {
  final PollData pollData;
  final Function(String)? onVote;

  const PollWidget({
    Key? key,
    required this.pollData,
    this.onVote,
  }) : super(key: key);

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  String? selectedOption;
  bool hasVoted = false;

  @override
  Widget build(BuildContext context) {
    final totalVotes = widget.pollData.options
        .fold<int>(0, (sum, option) => sum + option.votes.length);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.pollData.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.pollData.options.map((option) {
            final votePercentage = totalVotes > 0 
                ? (option.votes.length / totalVotes * 100).round()
                : 0;
            
            return _buildPollOption(
              option.option,
              option.id,
              votePercentage,
              option.votes.length,
              totalVotes,
            );
          }).toList(),
          const SizedBox(height: 12),
          Text(
            '$totalVotes votes',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollOption(
    String optionText,
    String optionId,
    int percentage,
    int votes,
    int totalVotes,
  ) {
    final isSelected = selectedOption == optionId;
    final showResults = hasVoted || totalVotes > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: hasVoted ? null : () => _handleVote(optionId),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: showResults
                ? (isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.05))
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              if (showResults)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (showResults)
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleVote(String optionId) {
    setState(() {
      selectedOption = optionId;
      hasVoted = true;
    });
    
    if (widget.onVote != null) {
      widget.onVote!(optionId);
    }
  }
}